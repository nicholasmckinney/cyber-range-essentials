#!/bin/bash

# check prereq for jq, aws cli
source ../shared/bash_functions.sh
security_account_name=security-operations
systems_account_name=systems-operations
vault_account_name=vault

Ask "Fully Qualified Domain Name (e.g. avid-security.com): "
read lab_domain

Success "Getting systems and vault account IDs"
aws_accounts=$(aws organizations list-accounts)
if [ $? -ne 0 ]; then
    Error "Failed to list accounts"
    exit 1
fi
systems_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$systems_account_name\").Id")
vault_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$vault_account_name\").Id")

Success "Creating necessary IAM service-linked role for SSM/CloudWatch"
export AWS_DEFAULT_REGION=us-east-1
ansible-playbook --connection=local --extra-vars "lab_domain=$lab_domain vault_account_id=$vault_account_id systems_account_id=$systems_account_id" ansible/ssm_iam.yml

pushd ansible/files/hybrid-management >/dev/null
ssm_activation_code=$(terraform output -raw ssm_activation_code)
ssm_activation_id=$(terraform output -raw ssm_activation_id)
ssm_key_id=$(terraform output -raw ssm_key_id)

if test -z "$ssm_activation_code"; then
  Error "Missing SSM activation code"
  exit 1
fi

if test -z "$ssm_activation_id"; then
  Error "Missing SSM activation id"
  exit 1
fi

if test -z "$ssm_key_id"; then
  Error "Missing SSM key"
  exit 1
fi

echo "Activation ID: $ssm_activation_id"
echo "SSM Encryption Key ID: $ssm_key_id"
popd >/dev/null

Success "Installing SSM Agent on hosts"
if [[ ! -z "$SKIP_SSM_INSTALL" ]]; then
  Warn "Skipping SSM agent installation"  
else
  ansible-playbook --ask-pass --ask-become-pass -i ansible/inventory --extra-vars "ssm_activation_code=$ssm_activation_code ssm_activation_id=$ssm_activation_id" ansible/ssm_install.yml
fi

Success "Enabling SSM Advanced Tier (for Fleet Manager and Sessions)"
aws ssm --profile systems update-service-setting --setting-id arn:aws:ssm:us-east-1:$systems_account_id:servicesetting/ssm/managed-instance/activation-tier --setting-value advanced

sed "s/KMS_KEY_ID_PLACEHOLDER/$ssm_key_id/; s/SYSTEMS_ACCOUNT_ID/$systems_account_id/" ssm.settings.json.template > ssm.settings.json

Success "Setting SSM logging preferences"
ssm_pref_doc_name=SSM-SessionManagerRunShell
ssm_pref_doc=$(aws ssm --profile get-document --name $ssm_pref_doc_name 2>&1)
if [[ ! -z "$ssm_pref_doc" ]]; then
  aws ssm --profile systems update-document --name $ssm_pref_doc_name --content "file://ssm.settings.json" --document-version "\$LATEST"
else
  aws ssm --profile systems create-document --name $ssm_pref_doc_name --content "file://ssm.settings.json" --document-type "Session" --document-format JSON 2>&1
fi

restrict_public_s3='BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'

Success "Denying public access to systems,vault buckets by default"
aws s3control --profile systems put-public-access-block --account-id $systems_account_id --public-access-block-configuration $restrict_public_s3
aws s3control --profile vault put-public-access-block --account-id $vault_account_id --public-access-block-configuration $restrict_public_s3
Success 'Done!'
