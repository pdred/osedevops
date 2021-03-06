#!/bin/bash

set -e

echo "Installing Open Shift prereq ..., base vbox must contains adequate subs"
yum update -y
subscription-manager repos --disable="*"
subscription-manager repos \
    --enable="rhel-7-server-rpms" \
    --enable="rhel-7-server-extras-rpms" \
    --enable="rhel-7-server-ose-3.2-rpms"
yum install wget git net-tools bind-utils iptables-services bridge-utils bash-completion -y
yum update -y
yum install atomic-openshift-utils -y

echo "Launch ansible-playbook"

ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ''

for host in 10.100.192.200 \
10.100.192.201 \
10.100.192.202; \
do sshpass -p "weareawesome" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub $host; \
done

#sshpass -p "weareawesome"  ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub 10.100.192.200

# prepare the machines
ansible-playbook /vagrant/ansible/oseprerequesites.yml -i /vagrant/ansible/hosts

for host in ose-master.example.com \
ose-utils.example.com \
ose-node-1.example.com; \
do sshpass -p "weareawesome" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub $host; \
done

# call ose installer
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml -i /vagrant/ansible/osehosts
# add users
ansible-playbook /vagrant/ansible/oseusers.yml -i /vagrant/ansible/hosts
# finish set up
ansible-playbook /vagrant/ansible/oseadditionalconf.yml -i /vagrant/ansible/hosts