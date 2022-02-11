#!/bin/bash

source ../shared/bash_functions.sh

./cf_setup.sh

Warn "Setting up AWS Organization..."
Ask "Fully Qualified Domain Name (e.g. example-lab-domain.com): "
read lab_domain

ansible-playbook -i ansible/inventory --extra-vars "lab_domain=$lab_domain"  ansible/organization_setup.yml

if [ $? -eq 0 ]; then
    Success "AWS Organization has been created!"
else
    Error "Failed to set up AWS Organization"
    exit 1
fi

# run terraform to create accounts

Warn "Creating AWS Organizations accounts..."
ansible-playbook -i ansible/inventory --extra-vars "lab_domain=$lab_domain" ansible/account_setup.yml
if [ $? -eq 0 ]; then
    Success "Successfully created AWS accounts!"
else
    Error "Failed to set up AWS Accounts"
fi

./aws_sso.sh
