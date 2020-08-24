#!/usr/bin/env bash

# start with the common setup
/usr/bin/env bash /vagrant/provisioning/ubuntu-focal-common.sh

echo "################################################################################"
echo "### Installing dependencies for rvm..."
echo "################################################################################"
sudo apt-get --quiet --yes install software-properties-common

# install rvm
cd /home/vagrant
echo "################################################################################"
echo "### Installing rvm..."
echo "################################################################################"
gpg --keyserver hkp://pool.sks-keyservers.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
curl -sSL https://get.rvm.io | bash -s stable
source /home/vagrant/.rvm/scripts/rvm

echo "################################################################################"
echo "### Downloading/building/installing ruby v2.7"
echo "################################################################################"
rvm install 2.7
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.6"
echo "################################################################################"
rvm install 2.6
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.5"
echo "################################################################################"
rvm install 2.5
if [ -f /home/vagrant/.bashrc ]; then
  echo "echo \"Available rubies:\"" >> /home/vagrant/.bashrc
  echo "rvm list" >> /home/vagrant/.bashrc
fi
