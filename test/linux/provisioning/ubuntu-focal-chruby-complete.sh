#!/usr/bin/env bash

# start with the common setup
/usr/bin/env bash /vagrant/provisioning/ubuntu-focal-common.sh

# install ruby-install
cd /home/vagrant
echo "################################################################################"
echo "### Downloading ruby-install..."
echo "################################################################################"
wget --quiet -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz
tar -xzf ruby-install-0.7.0.tar.gz && rm -f ruby-install-0.7.0.tar.gz
echo "################################################################################"
echo "### Building/installing ruby-install..."
echo "################################################################################"
cd ruby-install-0.7.0 && sudo make install && cd /home/vagrant && rm -rf ruby-install-0.7.0
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.7..."
echo "################################################################################"
ruby-install ruby 2.7
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.6..."
echo "################################################################################"
ruby-install ruby 2.6
echo "################################################################################"
echo "### Downloading/building/installing ruby v2.5..."
echo "################################################################################"
ruby-install ruby 2.5
echo "################################################################################"
echo "### Cleaning up..."
echo "################################################################################"
rm -rf src/ruby*

# install chruby
cd /home/vagrant
echo "################################################################################"
echo "### Downloading chruby..."
echo "################################################################################"
wget --quiet -O chruby-0.3.9.tar.gz https://github.com/postmodern/chruby/archive/v0.3.9.tar.gz
tar -xzf chruby-0.3.9.tar.gz && rm -f chruby-0.3.9.tar.gz
echo "################################################################################"
echo "### Building/installing chruby..."
echo "################################################################################"
cd chruby-0.3.9 && sudo make install && cd /home/vagrant && rm -rf chruby-0.3.9
if [ -f /home/vagrant/.bashrc ]; then
  echo "source /usr/local/share/chruby/chruby.sh" >> /home/vagrant/.bashrc
  echo "echo \"Available rubies:\"" >> /home/vagrant/.bashrc
  echo "chruby" >> /home/vagrant/.bashrc
fi
