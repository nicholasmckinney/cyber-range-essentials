#!/bin/bash

# check prereq for jq, aws cli
source ../shared/bash_functions.sh
security_account_name=security-operations
systems_account_name=systems-operations
vault_account_name=vault


aws_accounts=$(aws organizations list-accounts)
if [ $? -ne 0 ]; then
    Error "Failed to list accounts"
    exit 1
fi
systems_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$systems_account_name\").Id")

export AWS_DEFAULT_REGION=us-east-1
export TF_VAR_region=$AWS_DEFAULT_REGION
export TF_VAR_systems_account_id=$systems_account_id

pushd ansible/files/hybrid-management >/dev/null
terraform destroy -target aws_ssm_activation.hybrid_management
popd >/dev/null
