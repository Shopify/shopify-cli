---
title: Core commands
section: core
---

## `help`

Lists the available commands and describes what they do. The commands available will vary depending on whether you are inside a project directory, and what kind of project it is.

```console
$ shopify help
$ shopify -h
$ shopify --help
```

You can also use the `help` command or options to get more detailed information about a specific command:

```console
$ shopify help [command]
$ shopify [command] -h
$ shopify [command] --help
```

## `connect`

Connect an existing Shopify App CLI project with Shopify, such as a Partner account or a specific Shopify development store. This command re-creates the project’s `.env` file with your authentication tokens.

This is useful if you are working on one project across multiple computers, or collaborating with other developers using a version control system like git.

```console
$ shopify connect
```

## `create`

Create a new project of the specified type. The project will be created in a subdirectory of the current directory:

```console
$ shopify create
```

When running the `create` command on its own, the CLI will prompt you to choose a project type:

```console
$ shopify create
? What type of project would you like to create? (Choose with ↑ ↓ ⏎, filter with 'f')
> 1. Node.js App
  2. Ruby on Rails App
```

You can also specify the type of app you want to create using a subcommand:
- For a Node.js app: `node`
- For a Ruby on Rails app: `rails`

If you specify a type, then Shopify App CLI will skip ahead and prompt you to enter a name for your project:

```console
$ shopify create node
? App Name
> 
```

## `logout`

Log out of the currently authenticated partner organization and store. The `logout` command clears any invalid credentials. You’ll need to re-authenticate the next time you connect your project to Shopify.

```console
$ shopify logout
```

## `config`

Configure Shopify App CLI options. Currently there are two available options.

### `analytics`

Configure anonymous usage reporting by enabling or disabling analytics 
```console
$ shopify config analytics [ --status | --enable | --disable ]
```

### `tipoftheday`

Enable or disable Tip of the day with:
```console
$ shopify config tipoftheday [ --status | --enable | --disable ]
```

### `feature`
Configure active [feature sets](https://github.com/Shopify/shopify-app-cli/wiki/Feature-Sets) in the CLI. This command is used for development and debugging work on the CLI tool itself. Only alter it if you know what you're doing. Check the [Shopify App CLI development guide](https://github.com/Shopify/shopify-app-cli/wiki) for more information.
```console
$ shopify config feature [ feature_name ] [ --status | --enable | --disable ]
```
