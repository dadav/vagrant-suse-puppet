#!/usr/bin/env bash
echo "Adding puppet repo"
sudo rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-fedora-21.noarch.rpm
echo "installing puppet"
sudo yum install puppet -y