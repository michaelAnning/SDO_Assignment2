#!/bin/bash
set +ex

# Run Playbook Based on Inventory Settings
ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i inventory.yml -e 'record_host_keys=True' -u ec2-user --private-key SSH_PUBLIC_KEY playbook.yml

# todo add any additional variables
SSH_PUBLIC_KEY="../.ssh"
