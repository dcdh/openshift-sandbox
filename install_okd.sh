#!/bin/bash
ansible-playbook install_okd.yml --extra-vars "ansible_become_password=damien"
