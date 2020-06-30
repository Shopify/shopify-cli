---
title: Upgrade Shopify App CLI
section: getting-started
toc: false
redirect_from: "/upgrade/"
---

You can manage upgrades to Shopify App CLI with the package manager for your platform.

### Homebrew (macOS)

```console
$ brew update
$ brew upgrade shopify-cli
```

### apt (Debian, Ubuntu)

On Debian-based Linux distributions, download the latest `.deb` file for Shopify App CLI from the [releases page](https://github.com/Shopify/shopify-app-cli/releases) and install it to update.

```console
$ sudo apt install shopify-cli-x.y.z.deb
```

### yum (CentOS 8+, Fedora, Red Hat, SUSE)

On Red Hat–based Linux distributions, download the latest `.rpm` file for Shopify App CLI from the [releases page](https://github.com/Shopify/shopify-app-cli/releases) and install it to update.

```console
$ sudo yum install shopify-cli-x.y.z.rpm
```

### Ruby gem

```console
$ gem update shopify-cli
```