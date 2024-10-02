#!/bin/bash
dnf install ansible -y
dnf install python3.12-pip.noarch -y
pip3.12 install botocore boto3
ansible pull -i localhost, -U https://github.com/sriharsha6197/expense-ansible.git -e ansible_user=Centos -e ansible_password=DevOps321 -e role_name=${role_name}