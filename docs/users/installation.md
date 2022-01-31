# Installation

## Installation through RubyGems

The easiest method to install the Shopify CLI is through RubyGems:

```shell
$ gem install shopify-cli
```

## Installation for Windows Users

- Go to the [Ruby Intstaller Kit](https://rubyinstaller.org/downloads/) download the latest version.
- Run installer leave all boxes checked. Make sure to associate install with **PATH** Environment variable.
- *A PC restart my be required* - Restart the terminal or PowerShell in *admin mode*.
- Run `gem install shopify-cli` 
- After the installation is completed, run `shopify version`, if this outputs a version number you've successfully installed the CLI.

## Installation for macOS Users

- Make sure you have [Homebrew](https://brew.sh/) installed
- Open your terminal app
- Run `brew tap shopify/shopify`
- Run `brew install shopify-cli`
- After the installation is completed, run `shopify version`, if this outputs a version number you've successfully installed the CLI.
- If a runtime issue occurs after the run of the command please refer to issue [#1990](https://github.com/Shopify/shopify-cli/issues/1990).

### To upgrade Shopify CLI

#### Homebrew (Mac OS)

```shell
$ brew update
$ brew upgrade shopify-cli
```

## Installation for Debian and Ubuntu users through `apt`

1.- Download the latest `.deb` binary for Shopify CLI from the releases page.

2.- Install the downloaded file and make sure to replace /path/to/download/shopify-cli-x.y.z.deb with the path to your file's location:

```shell
$ sudo apt install /path/to/downloaded/shopify-cli-x.y.z.deb
```

## Installation for CentOS 8+, Fedora, Red Hat, and SUSE users through `yum`

1.- Download the latest .rpm file for Shopify App CLI from the releases page.

2.- Install the downloaded file and make sure to replace /path/to/downloaded/shopify-cli-x.y.x.rpm with the path to your file's location:

```shell
 $ sudo yum install /path/to/downloaded/shopify-cli-x.y.x.rpm
```
