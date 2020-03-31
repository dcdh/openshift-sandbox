#!/bin/bash
ansible-playbook uninstall_okd.yml --extra-vars "ansible_become_password=damien"
