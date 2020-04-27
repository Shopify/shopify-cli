---
title: Core commands
section: core
---

## `help`

Lists the available commands and describes what they do. The commands available will vary depending on whether you are inside a project directory, and what kind of project it is.

```sh
$ shopify help
$ shopify -h
$ shopify --help
```

You can also use the `help` command or flags to get more detailed information about a specific command:

```sh
$ shopify help [command]
$ shopify [command] -h
$ shopify [command] -help
```

## `connect`

Connect an existing Shopify App CLI project with Shopify, such as a Partner account or a specific Shopify development store. This command re-creates the project’s `.env` file with the necessary authentication tokens.

This is useful if you are working on one project across multiple computers, or collaborating with other developers using a version control system like git.

```sh
$ shopify connect
```

## `create`

Create a new project of the specified type. The project will be created in a subdirectory of the current directory:

```sh
$ shopify create
```

When running the `create` command on its own, the CLI will prompt you to choose a project type:

```sh
$ shopify create
? What type of project would you like to create? (Choose with ↑ ↓ ⏎, filter with 'f')
> 1. Node.js App
  2. Ruby on Rails App
```

You can also specify the type of app you want to create using a subcommand:
- For a Node.js app: `node`
- For a Ruby on Rails app: `rails`

If you specify a type, then Shopify App CLI will skip ahead and prompt you to enter a name for your project:

```sh
$ shopify create node
? App Name
> 
```

## `logout`

Log out of the currently authentiated organization and store. The `logout` command clears any invalid credentials. You will have to re-authenticate the next time you connect your project to Shopify.

```sh
$ shopify logout
```

## `update`

Update the Shopify App CLI to the latest version:

```sh
$ shopify update
```

