---
title: Migrate from the legacy Shopify App CLI
section: getting-started
redirect_from: "/migrate/"
---

As of version 0.9.0, Shopify App CLI is installed and managed as a software package, instead of as a git repository. If you’re using a legacy version, you’ll need to perform a one-time migration to keep using the CLI. Follow these steps to remove the legacy version and reinstall as a package.

## Check whether you’re using the legacy version

Prior to version 0.9.0, Shopify App CLI was installed as a Git repository. You can determine if you’re running a legacy version by running this command:

```console
$ shopify version
```

If you get a “Command not found” error, then you’re using a legacy version and will need to uninstall it manually.

## 1. Uninstall the legacy Shopify App CLI

There are two steps to completely uninstall the legacy version of Shopify App CLI:

1. Delete the legacy CLI files
1. Remove the legacy `shopify` command from your shell profile

### 1. Delete the CLI files

By default, Shopify App CLI was installed in your home directory. All the files are contained in a hidden directory called `.shopify-app-cli`. Delete it to uninstall:

```console
$ rm -rf ~/.shopify-app-cli/
```

### 2. Remove the `shopify` command from your shell

During the install process, Shopify App CLI added a line to your shell configuration. This line could be located in one of a few possible files in your home directory:

- `~/.bash_profile`
- `~/.zshrc`
- `~/.bash_login`
- `~/.profile`
- `~/.config/fish/config.fish`

It will look similar to this:

```sh
# The line won’t look *exactly* like this. `HOME_DIR` will instead be the absolute path to your home directory.
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi
```

Deleting or commenting out the relevant line in your shell profile will remove `shopify` as a command. You may need to reload your shell.

## 2. Install the new version

Next, install the most recent version of Shopify App CLI. Follow the [install directions]({{ site.baseurl }}/getting-started/install/) for your platform.

## 3. Re-authenticate the CLI

The upgrade process moves some configuration files, so you’ll need to re-authenticate the CLI with your Shopify Partner Dashboard. The CLI will automatically prompt you to re-authenticate when needed.

