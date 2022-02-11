#!/bin/bash

export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook -i ansible/inventory -k ansible/switch.yml
