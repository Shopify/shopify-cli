# Shopify App CLI [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you add features, such as billing and webhooks.

#### Table of Contents

- [Install](#install)
- [Getting started](#getting-started)
- [Commands](#commands)
- [Contributing to development](#developing-shopify-app-cli)
- [Uninstall](#uninstalling-shopify-app-cli)
- [Changelog](#changelog)

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

## Commands

### Create a new app project

Run the `create` command to scaffold a new Shopify app in your current directory and generate all the necessary starter files. You can create a Node or Rails app.

Run the following command:

```sh
$ shopify create app APP_NAME
```


### Start a development server

Run the `serve` command to start a local development server as well as a public tunnel to your local development app.

From your app directory, run the following command:
```sh
$ shopify serve
```
Your app is visible to anyone with the ngrok URL.

Your terminal displays the localhost and port where your app is visible. You can now go to your Partner Dashboard and install your app to your development store.

### Start or stop a tunnel to your localhost

Run the `tunnel` command to set up a public tunnel to your local app. Shopify App CLI uses [ngrok](https://ngrok.com/) to manage this connection. Starting a tunnel makes your app visible to anyone with this ngrok URL.

To start a tunnel:

Run the following command from your app directory:
```sh
$ shopify tunnel start
```

To stop the tunnel:

Run the following from your app directory:
```sh
$ shopify tunnel stop
```
### Preview your app and install it on your development store

Run the `open` command to install your app on a development store.

It's important to test your app in a development store because some App Bridge and Polaris features are only available for use by your app when it’s embedded in the Shopify admin.

To install your app on a store:

1. Run the following command from your app directory: `shopify open` The installation URL opens in your web browser.
2. When prompted, choose to install the app on your development store.


### Generate new app features

Run the `generate` command to create the resources for your app.

This command can create the following resources:

- Pages in your app
- App billing models and endpoints
- Webhooks to listen for store events

#### Create a new page

Run the following command from your app directory:

```sh
$ shopify generate page <page_name>
```
A new page is created in the `pages` directory. If your app is a Node app, then you can view this page by appending the page_name to the url.

#### Create a billing model

Set up the billing model for how merchants will pay you for your app.  You can set up a one-time billing model or a recurring subscription model.

Run the following command from your app directory:

```sh
$ shopify generate billing
```

#### Create a new webhook

Webhooks let your app listen for events that happen in the stores where your app is installed. You can register a new webhook for any store event.

A [list of supported webhook events](https://help.shopify.com/en/api/reference/events/webhook) is available in [Shopify’s API docs](https://help.shopify.com/en/api/getting-started).

Run the following command from your app directory:

```sh
$ shopify generate webhook WEBHOOK_NAME
```


### Add test data to a development store

Add example product, customer, and order data to your [development stores](https://help.shopify.com/en/partners/dashboard/development-stores).

By default the number of items added is 10, unless you use the `--count` option to specify a different amount.

Run the following commands from your app directory:

```sh
# Adds 10 fake products
$ shopify populate products

# Adds 10 fake customers
$ shopify populate customers

# Adds 25 fake orders
$ shopify populate draftorders --count 25
```

### Update your CLI software

Use the `update` command to update your production instance of the Shopify App CLI software to the latest version.

Run the following command from your app directory:

```sh
$ shopify update
```


## Developing Shopify App CLI

This is an [open-source](https://github.com/Shopify/shopify-app-cli/blob/master/.github/LICENSE.md) tool and developers are [invited to contribute](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CONTRIBUTING.md) to it. Please check the [code of conduct](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CODE_OF_CONDUCT.md) and the [design guidelines](https://github.com/Shopify/shopify-app-cli/blob/master/.github/DESIGN.md) before you begin.

If you need to run multiple instances of the Shopify App CLI (for example, to test your work). The `load-dev` and `laod-system` commands can be used to change between production and development instances of the Shopify App CLI.


### Load a development instance

Run the following commands:

```sh
# Clone the repo for development purposes
$ git clone git@github.com:Shopify/shopify-app-cli.git
# Configure the CLI to use your development instance
$ shopify load-dev `/path/to/instance`
```



### Reload the production instance

```sh
$ shopify load-system
```

### VM testing

A Vagrantfile is provided with some images for testing cross-platform. For more information see the [Vagrant docs](https://www.vagrantup.com/docs/).

To test the install script on Ubuntu, run the following command;

```
$ vagrant up ubuntu
$ vagrant ssh ubuntu
vagrant$ cd /vagrant
vagrant$ eval "$(cat install.sh)"
```

### Ruby console

Run `rake console` inside this repo to interact with the CLI's ruby API inside of an `irb` console.

Run the following command:

```
rake console
irb(main):001:0> ShopifyCli::ROOT
=> "/Users/me/src/github.com/Shopify/shopify-cli"
```

## Uninstalling Shopify App CLI

To uninstall Shopify App CLI:

1. Delete the CLI files.
2. Remove the `shopify` command from your shell profile.

### Delete the CLI files

With [the standard installation process](https://github.com/Shopify/shopify-app-cli#install), Shopify App CLI is installed in your home directory. All the files are contained in a hidden directory called `.shopify-app-cli`, which you can delete to uninstall.

### Remove the `shopify` command from your shell

During the install process, Shopify App CLI adds a line to your shell configuration. This line is typically located in the `.bash_profile` file in your home directory (depending on your system, it may also be found in `.bash_login` or `.profile`). It will look similar to this:

```sh
# The line won’t look exactly like this. `HOME_DIR` will instead be the absolute path to your home directory
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi
```

Deleting or commenting out this line will remove `shopify` as a command. You may need to reload your shell.

## Changelog

**Shopify create command changes**
The subcommand to create a project was renamed from `project` to `app`. February 11, 2020

**Context-sensitive commands**
Context-sensitivity has been added to the commands and help. When you run a command, your directory is used to decide if the command runs. Previously, you could run any command from any directory. Now you need to be in an app directory to run a command that affects an app. To create an app, you need to be in the root directory.

The following commands can be run from the root directory only:

* `create` - create an app project
* `update` - update the Shopify App CLI to the latest version
* `open`   - install your app on a development store
*  the open-source developer commands `load-dev` and `load-system`


The following commands can be run from an app directory:

* `deploy` - deploy your app to a hosting service
* `generate` - generate code for resources in your app.
* `populate` - add example objects to your development store.
*  the convenience commands for debugging: `authenticate`, `connect`, `serve`, and `tunnel`.
* `update` - update the Shopify App CLI to the latest version
*  the open-source developer commands `load-dev` and `load-system`

Also, when you run `shopify help` it returns the commands that apply to the project or directory that you are in. February 11, 2020
