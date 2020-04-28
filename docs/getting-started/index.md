---
title: Getting started
section: getting-started
---

Developers should have some prior knowledge of the [Shopify app ecosystem](https://shopify.dev/concepts/apps). Shopify App CLI creates apps using either [Node.js](https://nodejs.org/) or [Ruby on Rails](https://rubyonrails.org/).

## Requirements

- [Ruby](https://www.ruby-lang.org) 2.5.1+ 
- [Node.js](https://nodejs.org) 10.0.0+
- [curl](https://curl.haxx.se) 7.0.0+
- A [Shopify partner account](https://partners.shopify.com/signup)
- A [Shopify development store](https://help.shopify.com/en/partners/dashboard/development-stores#create-a-development-store) to install and test apps
- An [ngrok](https://ngrok.com/) account (free or paid) for local development

### Windows requirements

You’ll need to install the following tools to use Shopify App CLI on Windows:

- [Linux Subsystem for Windows](https://docs.microsoft.com/en-us/windows/wsl/install-win10)
- [Ubuntu VM](https://www.microsoft.com/en-ca/p/ubuntu/9nblggh4msv6)

## Install

Shopify App CLI installs using a shell script. Download and run it in your terminal with one command:

```console
eval "$(curl -sS https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh)"
```

([View shell script source](https://raw.githubusercontent.com/Shopify/shopify-app-cli/master/install.sh))


## Uninstall

There are two steps to completely uninstall Shopify App CLI:

1. Delete the CLI files
1. Remove the `shopify` command from your shell profile

### 1. Delete the CLI files

By default, Shopify App CLI is installed in your home directory. All the files are contained in a hidden directory called `.shopify-app-cli`. Delete that directory to uninstall.

### 2. Remove the `shopify` command from your shell

During the install process, Shopify App CLI adds a line to your shell configuration. This line is typically located in the `.bash_profile` file in your home directory (depending on your system, it may also be found in `.bash_login` or `.profile`). It will look similar to this:

```sh
# The line won’t look exactly like this. `HOME_DIR` will instead be the absolute path to your home directory.
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi
```

You can use `grep` to search for the correct file in your home directory. This command will return the name of the relevant file, and the line number where it appears:

```console
$ grep -Ens "^if.+\.shopify-app-cli/shopify\.sh.+fi$" ~/\.*
```

Deleting or commenting out the relevant line in your shell profile will remove `shopify` as a command. You may need to reload your shell.
