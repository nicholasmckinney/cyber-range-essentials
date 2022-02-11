#!/bin/bash
set -e
set +x

source ../shared/bash_functions.sh

###### JUMP Server: Graphical Bastion ################

# Uncomment to use with Google Workspace's Secure LDAP (requires a plan upgrade)
#Ask "Lab Domain: "
#read lab_domain

#Ask "LDAP Domain Component (dc=mydomain,dc=com)"
#read lab_dc
#############################

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory  --extra-vars "lab_domain=$lab_domain lab_dc=$lab_dc" --ask-pass --ask-become-pass -k ansible/jump.yml

######################################################

ssh-copy-id -i ../shared/id_ssh_rsa.pub sysadmin@10.0.20.10
