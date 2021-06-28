#!/usr/bin/env bash

# update linux system
echo "################################################################################"
echo "### Updating/upgrading system packages..."
echo "################################################################################"
sudo apt-get --quiet --yes update
sudo apt-get --quiet --yes upgrade

# install necessary packages for installing/using shopify-cli
echo "################################################################################"
echo "### Installing build-essential, unzip, libsqlite3-dev, libmysqlclient-dev, mysql-server..."
echo "################################################################################"
sudo apt-get --quiet --yes install build-essential
sudo apt-get --quiet --yes install unzip
sudo apt-get --quiet --yes install libsqlite3-dev
sudo apt-get --quiet --yes install libmysqlclient-dev
sudo apt-get --quiet --yes install mysql-server

# install latest version of node
echo "################################################################################"
echo "### Installing latest version of node/npm..."
echo "################################################################################"
curl -sL https://deb.nodesource.com/setup_current.x | sudo -E bash -
sudo apt-get --quiet --yes install nodejs

# install yarn
cd /home/vagrant
echo "################################################################################"
echo "### Installing yarn..."
echo "################################################################################"
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt-get --quiet --yes update && sudo apt-get --quiet --yes install yarn

# download a clone of the shopify-cli repo
cd /home/vagrant
echo "################################################################################"
echo "### Cloning shopify-cli..."
echo "################################################################################"
mkdir src && cd src && git clone https://github.com/Shopify/shopify-cli.git && cd /home/vagrant
echo "################################################################################"
echo "### Clone of shopify-cli located at ~/src/shopify-cli"
echo "################################################################################"
