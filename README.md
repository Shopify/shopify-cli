# shopify-app-cli [![Build status](https://badge.buildkite.com/a27554588a0e537d0ca23984dec9e68a16dc3f5ff41415cb08.svg?branch=master)](https://buildkite.com/shopify/shopify-app-cli)[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)

Until this is public the instructions below won't work. Instead:
```sh
dev clone shopify-app-cli && eval "$(cat install.sh)"
```

# Shopify App CLI

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you quickly add popular features, such as billing and webhooks.

## Install

Shopify App CLI installs using a shell script. Download and run it in your terminal with one command:

### Mac OS and Ubuntu
```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-cli/master/install.sh)"
```

### Windows
Install [Linux Subsystem for Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and the [Ubuntu VM](https://www.microsoft.com/en-ca/p/ubuntu/9nblggh4msv6), then:

```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-cli/master/install.sh)"
```

## Getting started

Developers should have some prior knowledge of the Shopify app ecosystem. Currently Shopify App CLI creates apps using either Node or Ruby.

### Requirements

- If you don’t have one, [create a Shopify partner account](https://partners.shopify.com/signup).
- If you don’t have one, [create a Development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) where you can install and test your app.
- In the Partner dashboard, [create a new app](https://help.shopify.com/en/api/tools/partner-dashboard/your-apps#create-a-new-app). You’ll need this app’s API credentials during the setup process.

## Commands

### Create a new app project

The `create` command will scaffold a new Shopify app in your current active directory and generate all the necessary files.

```sh
~/ $ shopify create project APP_NAME
```

The CLI will ask what type of app you want to create. Two languages and frameworks are currently supported:

- Node.js and React
- Ruby and Sinatra

The CLI will also ask for your app’s API key and API secret, which you can find in the Partner Dashboard.

### Start a development server

Running the `serve` command in your app directory will start a local development server.

```sh
$ shopify serve
```

Your terminal will display the localhost and port where your app is now visible.

### Start a tunnel to your localhost

Use `tunnel` to set up a public tunnel to your local app. Shopify App CLI uses [ngrok](https://ngrok.com/) under the hood to manage this connection:

```sh
$ shopify tunnel start
```

Use the `stop` command to close the tunnel:

```sh
$ shopify tunnel stop
```

### Generate new app features

Shopify App CLI automates several common developer tasks. Currently `generate` supports the following options:

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

The `populate` command can add fake products, customers, and orders. The default number of items added is 10. You can specify a different number of items with the `--count` option.

```sh
# Adds 10 fake products
$ shopify populate STORE_ID products

# Adds 10 fake customers
$ shopify populate STORE_ID customers

# Adds 25 fake orders
$ shopify populate STORE_ID orders --count 25
```

## Developing Shopify App CLI

This is an [open-source](https://github.com/Shopify/shopify-app-cli/blob/master/.github/LICENSE.md) tool and developers are [invited to contribute](https://github.com/Shopify/shopify-app-cli/blob/master/.github/CONTRIBUTING.md) to it.

That often requires having multiple instances of Shopify App CLI installed for testing purposes. There are two commands that give developers greater control over their Shopify App CLI environment:


### Load a development instance

```sh
$ shopify load-dev `/path/to/instance`
```

The `load-dev` command loads the version of Shopify App CLI specified between the backticks.

### Reload a development instance after making a change

```sh
$ shopify load-system
```

The `load-system` ensures you’re using the most recent version of Shopify App CLI after making a local change.