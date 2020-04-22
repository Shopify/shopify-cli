---
title: Introduction
---

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)[![Build Status](https://travis-ci.com/Shopify/shopify-app-cli.svg?token=qtPazgjyosjEEgxgq7VZ&branch=master)](https://travis-ci.com/Shopify/shopify-app-cli)

Shopify App CLI helps you build Shopify apps faster. It automates many common tasks in the development process and lets you quickly add popular features, such as billing and webhooks.

#### Table of contents

- [Install](#install)
- [Getting started](#getting-started)

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
