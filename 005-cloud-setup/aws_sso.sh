#!/bin/bash

# check prereq for jq, aws cli
source ../shared/bash_functions.sh
security_account_name=security-operations
systems_account_name=systems-operations
vault_account_name=vault

Ask "Fully Qualified Domain Name (e.g. avid-security.com): "
read lab_domain

aws_accounts=$(aws organizations list-accounts)
if [ $? -ne 0 ]; then
    Error "Failed to list accounts"
    exit 1
fi
security_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$security_account_name\").Id")
systems_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$systems_account_name\").Id")
vault_account_id=$(echo $aws_accounts | jq -e -r ".Accounts[] | select(.Name == \"$vault_account_name\").Id")

Ask "Using JumpCloud for SAML? If not using Jumpcloud, you must have set up Google Workspace (y/n)"
read use_jumpcloud

use_jumpcloud=no
if [[ "$use_jumpcloud" == "y" ]] || [[ "$use_jumpcloud" == "Y" ]]; then
    Warn "SAML configuration files must be present in shared directory with names jumpcloud-aws-root-saml.xml, jumpcloud-aws-secops-saml.xml, jumpcloud-aws-sysops-saml.xml, jumpcloud-aws-vault-saml.xml"
    use_jumpcloud=yes
fi
Warn "Creating SSO provider for IdP and (admin/power/read-only) roles in member accounts"
ansible-playbook -i ansible/inventory --extra-vars "use_jumpcloud=$use_jumpcloud lab_domain=$lab_domain security_account_id=$security_account_id systems_account_id=$systems_account_id vault_account_id=$vault_account_id" ansible/iam_setup.yml
