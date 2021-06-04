# Shopify CLI

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE.md)
[![Build Status](https://github.com/Shopify/shopify-cli/workflows/CI/badge.svg)](https://github.com/Shopify/shopify-cli/actions)


Shopify CLI helps you build Shopify themes and apps. Use the Shopify CLI to automate and enhance your local development workflow.

The Shopify CLI is available as a gem and can be run and installed on Mac, Linux and Windows systems. 

## Installation for Mac OS Users

- Make sure you have [Homebrew](https://brew.sh/) installed
- Open your terminal app
- Run `brew tap shopify/shopify`
- Run `brew install shopify-cli`
- After the installation is completed, run `shopify version`, if this outputs a version number you've successfully installed the CLI.

## Command specification and semantics

The shopify CLI offers a familiar command structure with other CLIs:

`shopify (RESOURCE | GLOBAL ACTION)  ACTION  VARIADIC ARGS`

The top level command will always be a **resource** or a **global action**:

- Resources represent Shopify concepts that you can work with in the CLI, for example `theme`.
- In general global actions are commands that alter the state of the CLI (e.g `config` or `login`)

Actions will always be verbs you can apply to resources or global actions.

When in doubt, add a `--help` or `-h` at the end of your command to get a full explanation of the available options for the command.

## Quick start guide for theme developers

This quick started guide will show you how to begin local theme development when working with a new theme from scratch.

### 1.- Authenticate the CLI

Once you installed the Shopify CLI the first recommended action when setting up your local development environment is that you authenticate your instance of the CLI. This will allow you to seamlessly develop themes.

Run:

`shopify login --shop=<your-shop-url>`

This will ask you to open a URL in your browser where you'll have to sign in to complete the OAuth process.

### 2.- Create a new theme

Run:

`shopify theme create`

To create a initialize a theme on your current working directory. This will actually clone Shopify Dawn which you should be use as a reference when building themes for Shopify.

### 3.- Start the local theme server

The Shopify CLI comes with a local theme server which lets you preview your changes live on your local machine. In order to have the same rendering experience that you'll expect in production we proxy your instance of the CLI to the Shopify rendering system.

Run:

`shopify theme serve`

To start the server. The server includes hot reload for CSS & Sections.

## Troubleshooting

### To upgrade the Shopify CLI

#### Homebrew (Mac OS)

```shell
$ brew update
$ brew upgrade shopify-cli
```

#### apt (Debian, Ubuntu)

1.- Download the latest `.deb` binary for the Shopify CLI from the releases page.

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

### Contributing

The Shopify CLI is an [open source tool](https://github.com/Shopify/shopify-cli/blob/master/.github/LICENSE.md) and everyone is welcome to help the community by [contributing](https://github.com/Shopify/shopify-cli/blob/master/.github/CONTRIBUTING.md) to the project.

### Where to get help

- [Open a GitHub issue](https://github.com/Shopify/shopify-cli/issues) - To report bugs or request new features, open an issue in the Shopify CLI repository.

- [Shopify Community Forums](https://community.shopify.com/) - Visit our forums to connect with the community and learn more about Shopify CLI development.