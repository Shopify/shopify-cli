---
title: Upgrade Shopify App CLI
section: getting-started
toc: false
redirect_from: "/upgrade/"
---

You can manage upgrades to Shopify App CLI with the package manager for your platform.  **Note** that it's important to use the same package manager to upgrade that you originally used to install Shopify App CLI.

### Homebrew (macOS)

```console
$ brew update
$ brew upgrade shopify-cli
```

### apt (Debian, Ubuntu)

On Debian-based Linux distributions, download the latest `.deb` file for Shopify App CLI from the [releases page](https://github.com/Shopify/shopify-app-cli/releases) and install it to update.

1. Download the `.deb` file from the [releases page](https://github.com/Shopify/shopify-app-cli/releases)
1. Install the downloaded file
```console
$ sudo apt install /path/to/downloaded/shopify-cli-x.y.z.deb
```

### yum (CentOS 8+, Fedora, Red Hat, SUSE)

On Red Hat–based Linux distributions, download the latest `.rpm` file for Shopify App CLI from the [releases page](https://github.com/Shopify/shopify-app-cli/releases) and install it to update.

1. Download the `.rpm` file from the [releases page](https://github.com/Shopify/shopify-app-cli/releases)
1. Install the downloaded file
```console
$ sudo yum install /path/to/downloaded/shopify-cli-x.y.x.rpm
```

### RubyGems (macOS, Linux, Windows 10)

```console
$ gem update shopify-cli
```