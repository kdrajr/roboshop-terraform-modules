#!/bin/bash

component=$1
environment=$2

REPO_URL=https://github.com/kdrajr/ansible-roboshop-roles-tf.git
ANSIBLE_DIR=/opt/roboshop/ansible
REPO_DIR=ansible-roboshop-roles-tf


dnf install ansible -y
mkdir -p $ANSIBLE_DIR
mkdir -p /var/log/roboshop
touch /var/log/roboshop/ansible.log

cd $ANSIBLE_DIR

if [ -d $REPO_DIR ]; then
    cd $REPO_DIR
    git pull
else
    git clone $REPO_URL
    cd $REPO_DIR
fi

ansible-playbook -i inventory.ini -e component=$component -e env=$environment main.yaml

