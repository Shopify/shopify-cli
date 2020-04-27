# Shopify App CLI [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you quickly add popular features, such as billing and webhooks.

#### Table of Contents

- [Install](#install)
- [Getting started](#getting-started)
- [Commands](#commands)
- [Contributing to development](#developing-shopify-app-cli)
- [Uninstall](#uninstalling-shopify-app-cli)

## Install

Shopify App CLI installs using a shell script. Download and run it in your terminal with one command:

### Mac OS and Ubuntu
```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh)"
```

### Windows
Install [Linux Subsystem for Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and the [Ubuntu VM](https://www.microsoft.com/en-ca/p/ubuntu/9nblggh4msv6), then:

```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh)"
```
> NOTE: Installing the Shopify App CLI requires [curl](https://curl.haxx.se/). You can to see if it's on your system by running: `curl --version`

## Getting started

Developers should have some prior knowledge of the Shopify app ecosystem. Currently Shopify App CLI creates apps using either Node or Ruby.

### Requirements

- If you don’t have one, [create a Shopify partner account](https://partners.shopify.com/signup).
- If you don’t have one, [create a Development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) where you can install and test your app.
- You should have Node.js version 10.0.0 or higher installed. If you're looking for a way to manage your node versions we recommend [nvm](https://github.com/nvm-sh/nvm/blob/master/README.md)

### Create a new project

The `create` command will scaffold a new Shopify app in your current active directory and generate all the necessary starter files.

```sh
$ shopify create
```

### Project Commands

Once inside a project you can find more commands available to you by running `shopify help`

There will be several commands available in a rails and node shopify app like

- `shopify serve` to start your local development server and a tunnel to make your app available inside shopify admin.
- `shopify open` to open the installation url and install the app on your development store
- `shopify generate webhook WEBHOOK_NAME` to generate configuration for recieving a webhook topic
- `shopify populate products` to populate product data on your development store
- Many more!

## Developing Shopify App CLI

This is an [open-source](https://github.com/Shopify/shopify-app-cli/blob/master/.github/LICENSE.md) tool and developers are [invited to contribute](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CONTRIBUTING.md) to it. Please check the [code of conduct](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CODE_OF_CONDUCT.md) and the [design guidelines](https://github.com/Shopify/shopify-app-cli/blob/master/.github/DESIGN.md) before you begin.

Developing Shopify App CLI often requires having multiple instances of the tool installed for testing purposes. There are two commands that give developers greater control over their Shopify App CLI environment:


### Load a development instance

```sh
# Clone the repo for development purposes
$ git clone git@github.com:Shopify/shopify-app-cli.git
# Configure the CLI to use your development instance
$ shopify load-dev `/path/to/instance`
```

The `load-dev` command loads the version of Shopify App CLI specified between the backticks.

### Reload the production instance

```sh
$ shopify load-system
```

The `load-system` command resets the CLI to use the production instance.

### VM testing

A Vagrantfile is provided with some images for testing cross-platform. For more information see the [Vagrant docs](https://www.vagrantup.com/docs/). Here's how to test the install script on Ubuntu.

```
$ vagrant up ubuntu
$ vagrant ssh ubuntu
vagrant$ cd /vagrant
vagrant$ eval "$(cat install.sh)"
```

### Ruby console

You can run `rake console` inside this repo to interact with the CLI's ruby API inside of an `irb` console.

```
rake console
irb(main):001:0> ShopifyCli::ROOT
=> "/Users/me/src/github.com/Shopify/shopify-cli"
```

## Uninstalling Shopify App CLI

There are two steps to completely uninstall Shopify App CLI:

1. Delete the CLI files.
1. Remove the `shopify` command from your shell profile.

### Delete the CLI files

With [the standard installation process](https://github.com/Shopify/shopify-app-cli#install), Shopify App CLI is installed in your home directory. All the files are contained in a hidden directory called `.shopify-app-cli`, which you can delete to uninstall.

### Remove the `shopify` command from your shell

During the install process, Shopify App CLI adds a line to your shell configuration. This line is typically located in the `.bash_profile` file in your home directory (depending on your system, it may also be found in `.bash_login` or `.profile`). It will look similar to this:

```sh
# The line won’t look exactly like this. `HOME_DIR` will instead be the absolute path to your home directory
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi
```

Deleting or commenting out this line will remove `shopify` as a command. You may need to reload your shell.

## Contributing to Shopify App CLI

See our [Development Guide](https://github.com/Shopify/shopify-app-cli/wiki).
