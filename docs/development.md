# Development notes

## ShopifyCli::Context

## What to use it for
- Reading from the user's ENV
- Executing things: `system`, `capture2`, `exec`, etc.
- Displaying output


## ShopifyCli::Project

## What to use it for
- Accessing information about the current project (app/codebase):
    - You can read from the `.env` file with the `Project.env` method
    - Accessing the `AppType` via `Project.app_type`
