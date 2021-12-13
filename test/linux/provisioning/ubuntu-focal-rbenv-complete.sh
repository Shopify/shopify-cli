#!/usr/bin/env bash

# start with the common setup
/usr/bin/env bash /vagrant/provisioning/ubuntu-focal-common.sh

echo "################################################################################"
echo "### Installing dependencies for rbenv..."
echo "################################################################################"
sudo apt-get --quiet --yes install libreadline-dev zlib1g-dev

# install rb-env
cd /home/vagrant
echo "################################################################################"
echo "### Downloading/building/installing rb-env & ruby-build..."
echo "################################################################################"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer | bash
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.7.5"
echo "################################################################################"
rbenv install 2.7.5
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.6.6"
echo "################################################################################"
rbenv install 2.6.6
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.5.8"
echo "################################################################################"
rbenv install 2.5.8
rbenv rehash
if [ -f /home/vagrant/.bashrc ]; then
  echo "export PATH=\$HOME/.rbenv/bin:\$PATH" >> /home/vagrant/.bashrc
  echo "eval \"\$(rbenv init -)\"" >> /home/vagrant/.bashrc
  echo "echo \"Available rubies:\"" >> /home/vagrant/.bashrc
  echo "rbenv versions" >> /home/vagrant/.bashrc
fi
