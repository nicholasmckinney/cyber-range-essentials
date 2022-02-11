#!/bin/bash

source ../shared/bash_functions.sh

Ask "Home CIDR: "
read home_net

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory --extra-vars "home_net=$home_net"  ansible/main.yml
