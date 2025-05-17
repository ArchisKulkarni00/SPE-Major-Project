#!/bin/bash
# scripts/run_as_linuxboi.sh

set -e

echo "[INFO] Running Ansible playbook as linuxboi..."

sudo -u linuxboi -H bash -c '
  cd /tmp/ansible-college-chatbot || exit 1
  ansible-playbook ./ansible/deploy.yml -i ./ansible/inventory
'
