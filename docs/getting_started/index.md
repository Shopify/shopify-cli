---
title: Getting started
section: getting_started
---

## Getting started

Developers should have some prior knowledge of the [Shopify app ecosystem](https://shopify.dev/concepts/apps). Currently, Shopify App CLI creates apps using either [Node.js](https://nodejs.org/) or [Ruby on Rails](https://rubyonrails.org/).

### Install

Shopify App CLI installs using a shell script. Download and run it in your terminal with one command:

#### Mac OS and Ubuntu
```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh)"
```

#### Windows
Install [Linux Subsystem for Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and the [Ubuntu VM](https://www.microsoft.com/en-ca/p/ubuntu/9nblggh4msv6), then:

```sh
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh)"
```

> NOTE: Installing the Shopify App CLI requires [curl](https://curl.haxx.se/). You can to see if it's on your system by running: `curl --version`

### Requirements to create a project

- If you don’t have one, [create a Shopify partner account](https://partners.shopify.com/signup).
- If you don’t have one, [create a development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) where you can install and test your app.
- You should have Node.js version 10.0.0 or higher installed. If you're looking for a way to manage your node versions we recommend [nvm](https://github.com/nvm-sh/nvm/blob/master/README.md)

### Uninstall

There are two steps to completely uninstall Shopify App CLI:

1. Delete the CLI files.
2. Remove the shopify command from your shell profile.

#### Delete the CLI files

With the standard installation process, Shopify App CLI is installed in your home directory. All the files are contained
 in a hidden directory called `.shopify-app-cli`, which you can delete to uninstall.

#### Remove the `shopify` command from your shell

During the install process, Shopify App CLI adds a line to your shell configuration. This line is typically located in the `.bash_profile` file in your home directory (depending on your system, it may also be found in `.bash_login` or 
  `.profile`). It will look similar to this:

```
# The line won’t look exactly like this. `HOME_DIR` will instead be the absolute path to your home directory
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi
```

Deleting or commenting out this line will remove `shopify` as a command. You may need to reload your shell.
