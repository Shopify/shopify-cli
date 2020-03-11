# Shopify App CLI Development Guide

This document describes the architecture of the Shopify App CLI and some principles we adhered to when designing it. This is valuable context to have for anyone contributing to this project’s development.

## Principles

### Speed
The CLI should execute quickly, getting things done and returning to the prompt as soon as possible. In dealing with other languages and external services we may incur unavoidable latency, but the core execution and boot of the CLI should remain instantaneous.

### No dependencies
Because ruby objects are loaded into memory, the fewer runtime dependencies we `require` the better. We have only two depedencies: [cli-kit][cli-kit] and [cli-ui][cli-ui]. They are vendored in the codebase to avoid using bundler or sourcing gems, which can add latency.

### Don’t require escalated privileges
If possible don’t `sudo` or require passwords for any task. Most open-source tools avoid using escalated privileges. If they do, it’s usually left to the user to execute as a part of a specific action (`sudo make install`, for example). Adhering to this principle enforces trust, as developers are hesitant to use a tool that could do anything on their machine.

### Don’t call home without user’s permission
Similar to the previous point, developers are resistant to use developer tools that make network requests without their consent. We have implemented opt-in anonymized usage reporting so we can track the CLI’s most-used features and improve its stability and reliability.

### Don’t delete stuff
Any operation executed by the tool should be non-destructive. Leave it up to the user to remove things created by the tool if they wish.

## How the CLI works

### The install script

A [shell script][install] ensures the user’s system has the necessary dependencies installed and handles cloning this repository to their filesystem. Cloning allows us to ensure the user is always running the latest code. It also installs a shell hook into the user’s `bash`, `zsh` or `fish` configuration.

### The shell hook

Subprocesses running in shells are unable to effect certain persistent changes to the user’s shell, such as changing their current directory, permanently changing environment variables, or reloading the CLI itself. A way around this is to use [a shell hook][hook], a script that runs after the execution of commands in the shell that can receive messages from the CLI process and perform these actions. The [`Finalize`][finalize] class handles sending these messages to the hook to be executed.

### The entry point

[`entry_point`][entry] is the first thing executed by the `shopify` executable. It’s in charge of taking [ARGV][argv] and translating it into a `Command`, along with any behavior we need to do during every execution, such as analytics.

## The Command Registry

The [Command Registry][command_registry] keeps track of the Commands that can be run by the CLI.

## Anatomy of a Command

### The call method

Every Command has a `call` method, which is the starting point for its behavior.

### Separation of Concerns

Commands should deal with the user interface, options and arguments, serializing them as necessary, and calling Tasks to perform complex logic.

## ShopifyCli::Context

## What to use it for
- Reading from the user’s ENV
- Executing things: `system`, `capture2`, `exec`, etc.
- Displaying output

## ShopifyCli::Project

## What to use it for
- Accessing information about the current project (app/codebase):
    - You can read from the `.env` file with the `Project.env` method
    - Accessing the `AppType` via `Project.app_type`

[cli-kit]:https://github.com/Shopify/cli-kit
[cli-ui]:https://github.com/Shopify/cli-ui
[install]: https://github.com/Shopify/shopify-app-cli/blob/master/install.sh
[hook]:https://github.com/Shopify/shopify-app-cli/blob/master/shopify.sh
[finalize]:https://github.com/Shopify/shopify-app-cli/blob/master/lib/shopify-cli/finalize.rb
[entry]:https://github.com/Shopify/shopify-app-cli/blob/master/lib/shopify-cli/entry_point.rb
[command_registry]:https://github.com/Shopify/shopify-app-cli/blob/master/vendor/deps/cli-kit/lib/cli/kit/command_registry.rb