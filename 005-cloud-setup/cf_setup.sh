#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False
source ../shared/bash_functions.sh

Ask "Lab Domain: "
read lab_domain

Ask "Email address for Cloudflare: "
read cf_email

export CLOUDFLARE_EMAIL=$cf_email
export CLOUDFLARE_API_KEY=$(cat $HOME/.cloudflare/api_key)

export AWS_ACCESS_KEY_ID=$(cat ~/.aws/credentials | grep aws_access_key_id | cut -d '=' -f2)
export AWS_SECRET_ACCESS_KEY=$(cat ~/.aws/credentials | grep aws_secret_access_key | cut -d '=' -f2)

Warn "Configuring domain with Cloudflare"
ansible-playbook --extra-vars "lab_domain=$lab_domain"  ansible/cf_zone.yml
