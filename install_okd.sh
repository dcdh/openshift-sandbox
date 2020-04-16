#!/bin/bash


wget -O /tmp/jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 && \
  chmod +x /tmp/jq && \
  sudo mv /tmp/jq /usr/local/bin/ && \
  ansible-playbook install_okd.yml --extra-vars "ansible_become_password=damien"
