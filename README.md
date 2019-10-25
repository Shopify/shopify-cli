# Shopify App CLI [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you quickly add popular features, such as billing and webhooks.

> ⚠️ NOTE: This tool is currently a beta release in active development. Some features may be absent or incomplete, and functionality may change without warning. We welcome your feedback! Please check the [contributing guide](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CONTRIBUTING.md) for notes on how to file bug reports and pull requests.

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

## Commands

### Create a new app project

The `create` command will scaffold a new Shopify app in your current active directory and generate all the necessary starter files.

```sh
$ shopify create project APP_NAME
```

The CLI will ask what type of app you want to create. Two languages are currently supported:

- Node.js and React
- Ruby

The CLI will also ask for your app’s API key and API secret, which you can find in your Partner Dashboard (see “Requirements” above).

### Start a development server

Running the `serve` command in your app directory will start your local development server as well as a public tunnel to your local development app (see the `tunnel` command below). This will make your app visible to anyone with the ngrok URL.

```sh
$ shopify serve
```

Your terminal will display the localhost and port where your app is now visible.

### Start or stop a tunnel to your localhost

Use `tunnel` to set up a public tunnel to your local app. Shopify App CLI uses [ngrok](https://ngrok.com/) to manage this connection. Starting a tunnel will make your app visible to anyone with the ngrok URL.

```sh
$ shopify tunnel start
```

Use the `stop` command to close the tunnel:

```sh
$ shopify tunnel stop
```
### Loading your app within the admin

As the Shopify App CLI creates an embedded app, you'll need to install it on a development store. To do so, open the installation URL in your web browser:  `https://<LIVE_NGROK_URL>/auth?shop=your-development-store.myshopify.com`. This will prompt you to install on your development store. It’s necessary to view and test your app in a live development store because some App Bridge and Polaris features are only available for use by your app when it’s embedded in the Shopify admin.

### Generate new app features

Shopify App CLI automates several common developer tasks. Currently `generate` supports the following actions:

- Generating new pages in your app
- Generating new billing models and endpoints
- Generating new webhooks to listen for store events

#### Create a new page

```sh
$ shopify generate page PAGE_NAME
```
The CLI will scaffold the new page in the `pages` directory.

#### Create a billing model

```sh
$ shopify generate billing
```
The CLI will ask whether you want to create a one-time billing model or a recurring subscription model.

#### Create a new webhook

Webhooks allow your app to listen for events that happen on any stores that have it installed. The CLI can quickly register a new webhook for any valid store event.

```sh
$ shopify generate webhook WEBHOOK_NAME
```

A [list of supported webhook events](https://help.shopify.com/en/api/reference/events/webhook) is available in [Shopify’s API docs](https://help.shopify.com/en/api/getting-started).

### Add test data to a development store

Developers can use [development stores](https://help.shopify.com/en/partners/dashboard/development-stores) to test their apps. Development stores have no products, customers or orders when they’re created. Shopify App CLI can quickly add dummy data to your development store so you can test your app more thoroughly.

The `populate` command can add fake products, customers, and draftorders. The default number of items added is 10. You can specify a different number of items with the `--count` option.

```sh
# Adds 10 fake products
$ shopify populate products

# Adds 10 fake customers
$ shopify populate customers

# Adds 25 fake orders
$ shopify populate draftorders --count 25
```

### Update to the latest version

```sh
$ shopify update
```

The `update` command will upgrade your production instance of the CLI to use the most recent version.

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
