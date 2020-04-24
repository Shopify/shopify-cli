---
title: Core commands
section: core
---

## Core commands

### help

- `shopify help` lists available commands. The commands available will vary depending on whether you are inside of a project 
  directory, and what kind of project it is.
- `shopify help [command]` shows detailed help for a specific command.

### connect

- `shopify connect` will re-connect an existing Shopify App CLI project to Shopify systems (e.g. a Partners account or
  a specific shop). This is useful if you are working on a project in source control and check out the code on another
  machine. It re-creates a `.env` file with the necessary information.

### create

- `shopify create [project type]` creates a new project of the specified type. The project will be created in a  
  subdirectory of the current directory. If you do not specify a project type, the CLI will prompt you to choose one. 
  Different project types have additional options that can be set or provided through prompts.

### logout

- `shopify logout` will log out of a currently authenticated organization and shop, or clear any invalid credentials.

### update

- `shopify update` updates the Shopify App CLI to the latest version.

