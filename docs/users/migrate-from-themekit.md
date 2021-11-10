# Migrate from Theme Kit

Shopify CLI is the recommended and officially supported tool for developing Themes and creating CI/CD workflows.

This guide shows how to achieve equivalent flows with the new version of the CLI.

## Equivalent commands

| Theme Kit Command | Shopify CLI Equivalent | Objective |
|---|---|---|
|`theme deploy`|`shopify theme push`| Deploy a local (to the CLI) version of the Theme in the current working directory to a remote store.|
|`theme new`|`shopify theme init`| Scaffold a new theme. In the case of the CLI it clones Dawn to be used as a reference Theme. Alternatively, it's possible to simply clone Dawn `git clone git@github.com:Shopify/dawn.git` and use it with the CLI.
|`theme download`|`shopify theme pull`| Download your remote theme files.|
|`theme watch` & `theme open` | `shopify theme serve` | Start a theme server to locally preview changes with CSS & Section hot reload enabled|
|-| `shopify theme check`| Run the Theme Check linter on your theme codebase.|
|-|`shopify theme publish`| Set a remote theme as the live theme.|
|-|`shopify theme package`|Pack your Theme as a zip file ready for distribution and submission to the Theme Store.|
|`theme remove`| `shopify theme delete`| Theme kit removes files from the Theme whereas Shopify CLI will remotely destroy the specified theme.|