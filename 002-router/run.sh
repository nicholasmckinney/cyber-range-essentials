#!/bin/bash


source ../shared/bash_functions.sh

Ask "Lab Domain: "
read lab_domain


export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_PERSISTENT_COMMAND_TIMEOUT=120
ansible-playbook -i ansible/inventory -e "lab_domain=$lab_domain" -k ansible/vyos.yml
