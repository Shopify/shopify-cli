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

### To check that Shopify App CLI is installed correctly:

```console
$ shopify version
1.0.0
$
```

> Note 1: the version displayed may be newer.

> Note 2: If you have the `shopify_api` gem installed, you may see the following response:
> ```console
> shopify command is no longer bundled with shopify_api.
> if you need these tools, install the shopify_cli gem
> ```
> 
> If so, then you will also need to upgrade the `shopify_api` gem to v9.2.0+ to remove a deprecated `shopify` command that is contained in that gem.
>
> If you also have the `shopify_app` gem (which depends on `shopify_api` gem), you'll need to install or update `shopify_api` first, then uninstall the older version.
> 
> To get a list of the version(s) of `shopify_api` currently installed:
> ```console
> $ gem list shopify_api
> ```
> 
> To install the latest version:
> ```console
> $ gem install shopify_api
> ```
> 
> To uninstall the older version:
> ```console
> $ gem uninstall shopify_api -v x.y.z
> ```
> Replace x.y.z with a version number listed from the `gem list` command.  Repeat as needed.
