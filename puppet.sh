#!/usr/bin/env bash

PUPPET_VERSION="5"
SLES_VERSION="12"

echo "Adding puppet repo"
sudo rpm -ivh https://yum.puppetlabs.com/puppet${PUPPET_VERSION}/puppet5-release-sles-${SLES_VERSION}.noarch.rpm
sudo zypper --gpg-auto-import-keys ref
echo "installing puppet"
sudo zypper -n install puppet
