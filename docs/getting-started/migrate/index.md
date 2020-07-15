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
1. Reload your terminal

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

It will look similar to one of the lines below. The exact syntax may vary depending on your system:

```sh
# The line won’t look *exactly* like this. `HOME_DIR` will instead be the absolute path to your home directory.
if [[ -f /HOME_DIR/.shopify-cli/shopify.sh ]]; then source /HOME_DIR/.shopify-cli/shopify.sh; fi

# The line might not be wrapped in an `if` statement. Example:
[ -f "/HOME_DIR/.shopify-app-cli/shopify.sh" ] && source "/HOME_DIR/.shopify-app-cli/shopify.sh"
```

Deleting or commenting out the relevant line in your shell profile will remove `shopify` as a command.

### 3. Reload your terminal

For the changes above to take effect, exit your terminal, and start a new one.

If you try running `shopify` now, you should get a `command not found` error.

> If you have the `shopify_api` gem installed, you may see the following response:
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

## 2. Install the new version

Next, install the most recent version of Shopify App CLI. Follow the [install directions]({{ site.baseurl }}/getting-started/install/) for your platform.

## 3. Re-authenticate the CLI

The migration process moves some configuration files, so you’ll need to re-authenticate the CLI with your Shopify Partner Dashboard. The CLI will automatically prompt you to re-authenticate when needed.

