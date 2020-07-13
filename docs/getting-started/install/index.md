---
title: Install Shopify App CLI
section: getting-started
toc: false
redirect_from: "/install/"
---

Shopify App CLI can be installed using a variety of package managers.

### Homebrew (macOS)

You’ll need to run `brew tap` first to add Shopify’s third-party repositories to Homebrew.

```console
$ brew tap shopify/shopify
$ brew install shopify-cli
```

### apt (Debian, Ubuntu)

You’ll need to install a downloaded .deb file with an explicit version number. Check the [releases page](https://github.com/Shopify/shopify-app-cli/releases) to make sure you install the latest package.

```console
$ sudo apt install shopify-cli-x.y.z.deb
```

### yum (CentOS 8+, Fedora, Red Hat, SUSE)

You’ll need to install a downloaded .rpm file with an explicit version number. Check the [releases page](https://github.com/Shopify/shopify-app-cli/releases) to make sure you install the latest package.

```console
$ sudo yum install shopify-cli-x.y.x.rpm
```

### Ruby gem

```console
$ gem install shopify-cli
```