#!/bin/bash
set -e
set +x

source ../shared/bash_functions.sh

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory  --extra-vars "os_release=$UBUNTU_CODENAME" --ask-pass --ask-become-pass --limit proxy -k ansible/tailscale.yml
