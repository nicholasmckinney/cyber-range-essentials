#!/bin/bash
set -e
set +x

source ../shared/bash_functions.sh


Ask "Lab Domain: "
read lab_domain


export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory  --extra-vars "lab_domain=$lab_domain" --ask-pass --ask-become-pass -k ansible/main.yml

ssh-copy-id -i ../shared/id_ssh_rsa.pub sysadmin@10.0.10.10
