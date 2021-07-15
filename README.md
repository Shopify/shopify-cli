# Shopify CLI

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)
[![Build Status](https://github.com/Shopify/shopify-cli/workflows/CI/badge.svg)](https://github.com/Shopify/shopify-cli/actions)


Shopify CLI helps you build Shopify themes and apps. Use Shopify CLI to automate and enhance your local development workflow.

Shopify CLI is available as a gem and can be run and installed on Mac, Linux and Windows systems.

## Installation for Mac OS Users

- Make sure you have [Homebrew](https://brew.sh/) installed
- Open your terminal app
- Run `brew tap shopify/shopify`
- Run `brew install shopify-cli`
- After the installation is completed, run `shopify version`, if this outputs a version number you've successfully installed the CLI.

### To upgrade Shopify CLI

#### Homebrew (Mac OS)

```shell
$ brew update
$ brew upgrade shopify-cli
```

#### apt (Debian, Ubuntu)

1.- Download the latest `.deb` binary for Shopify CLI from the releases page.

2.- Install the downloaded file and make sure to replace /path/to/download/shopify-cli-x.y.z.deb with the path to your file's location:

```shell
$ sudo apt install /path/to/downloaded/shopify-cli-x.y.z.deb
```

#### yum (CentOS 8+, Fedora, Red Hat, SUSE)

1.- Download the latest .rpm file for Shopify App CLI from the releases page.

2.- Install the downloaded file and make sure to replace /path/to/downloaded/shopify-cli-x.y.x.rpm with the path to your file's location:

```shell
 $ sudo yum install /path/to/downloaded/shopify-cli-x.y.x.rpm
```

#### RubyGems (macOS, Linux, Windows 10)

```shell
$ gem update shopify-cli
```


## Command specification and semantics

Shopify CLI offers a command structure similar to other CLIs:

`shopify [ GLOBAL_ACTION | RESOURCE [ ACTION ] ] [ VARIADIC_ARGS ] [ OPTIONS ]`

The top level command will always be a **resource** or a **global action**:

- Resources represent Shopify concepts that you can work with in the CLI, for example `theme`.
- Usually, global actions are commands that alter the state of the CLI (e.g `config` or `login`)

Actions are commands that you can run to interact with a resource.

You can add `--help` or `-h` to the end of your command to get a full explanation of the available options for the command.

## Quick start guide for theme developers

This quick start guide shows you how to begin local theme development when working with a new theme from scratch.

### 1.- Authenticate the CLI

After you install Shopify CLI, you need to authenticate your CLI instance and connect to the store that you want to work on.

Run:

`shopify login --store=<your-shop-url>`

When prompted, open the provided accounts.shopify.com URL in a browser. In your browser window, log into the account that's attached to the store that you want to use for development.

### 2.- Create a new theme

Run:

`shopify theme init`

To initialize a theme on your current working directory. This will actually clone Shopify's starter theme which you should use as a reference when building themes for Shopify.

### 3.- Start the local theme server

Shopify CLI comes with a local theme server which lets you preview your changes live on your local machine.

After you create or navigate to your theme, you can run `shopify theme serve` to interact with the theme in a browser. Shopify CLI uploads the theme as a development theme on the store that you're connected to, and gives you an IP address and port to preview changes in real time using the store's data.

Run:

`shopify theme serve`

To start the server. The server includes hot reload for CSS & Sections.

**Note:** Shopify CLI is the recommended and officially supported tool for developing themes and creating CI/CD workflows. Please refer to the [Theme Kit Migration Guide](https://github.com/Shopify/shopify-cli/blob/main/THEMEKIT_MIGRATION.md) for details.

### Contributing

Shopify CLI is an [open source tool](https://github.com/Shopify/shopify-cli/blob/main/LICENSE) and everyone is welcome to help the community by [contributing](https://github.com/Shopify/shopify-cli/blob/main/.github/CONTRIBUTING.md) to the project.

### Where to get help

- [Open a GitHub issue](https://github.com/Shopify/shopify-cli/issues) - To report bugs or request new features, open an issue in the Shopify CLI repository.

- [Shopify Community Forums](https://community.shopify.com/) - Visit our forums to connect with the community and learn more about Shopify CLI development.
