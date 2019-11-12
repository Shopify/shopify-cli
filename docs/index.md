# Shopify App CLI [![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you quickly add popular features, such as billing and webhooks.

#### Table of Contents

- [Install](#install)
- [Getting started](#getting-started)
- [Commands](#commands)

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
