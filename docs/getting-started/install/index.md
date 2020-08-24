---
title: Install Shopify App CLI
section: getting-started
toc: false
redirect_from: "/install/"
---

Shopify App CLI can be installed on a variety of systems, using a variety of package managers.
> Note that for systems that have multiple installation options, you only need to use one of these methods to install.

---
### macOS

Shopify App CLI is available through Homebrew _or_ RubyGems.

**Homebrew**

You’ll need to run `brew tap` first to add Shopify’s third-party repositories to Homebrew.

```console
$ brew tap shopify/shopify
$ brew install shopify-cli
```

**RubyGems**

See the [RubyGems]({{ site.baseurl }}/getting-started/install/#rubygems-all-platforms) section for further details.

---

### Debian/Ubuntu Linux

On Debian-based Linux systems, Shopify App CLI is available through the `apt` command _or_ RubyGems.

**apt**

You’ll need to install a downloaded `.deb` file with an explicit version number. Check the [releases page](https://github.com/Shopify/shopify-app-cli/releases) to make sure you install the latest package.

1. Download the `.deb` file from the [releases page](https://github.com/Shopify/shopify-app-cli/releases)
1. Install the downloaded file
```console
$ sudo apt install /path/to/downloaded/shopify-cli-x.y.z.deb
```

**RubyGems**

See the [RubyGems]({{ site.baseurl }}/getting-started/install/#rubygems-all-platforms) section for further details.

---

### CentOS 8+/Fedora/Red Hat/SUSE Linux

On RPM-based Linux systems, Shopify App CLI is available through the `yum` command _or_ RubyGems.

**yum**

You’ll need to install a downloaded `.rpm` file with an explicit version number. Check the [releases page](https://github.com/Shopify/shopify-app-cli/releases) to make sure you install the latest package.

1. Download the `.rpm` file from the [releases page](https://github.com/Shopify/shopify-app-cli/releases)
1. Install the downloaded file
```console
$ sudo yum install /path/to/downloaded/shopify-cli-x.y.x.rpm
```

**RubyGems**

See the [RubyGems]({{ site.baseurl }}/getting-started/install/#rubygems-all-platforms) section for further details.

---

### Windows 10

On Windows 10 systems, Shopify App CLI is available through [RubyGems]({{ site.baseurl }}/getting-started/install/#rubygem-all-platforms).

---

### RubyGems (all platforms)

Shopify App CLI is available on all platforms as a RubyGem through [RubyGems.org](https://rubygems.org/).

```console
$ gem install shopify-cli
```

---

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
