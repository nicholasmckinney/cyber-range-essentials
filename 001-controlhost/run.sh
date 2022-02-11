#!/bin/bash

if [ "$EUID" != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

mkdir ../shared
./install_ansible.sh
ansible-playbook -i ansible/inventory --ask-become-pass ansible/controlhost.yml
