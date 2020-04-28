---
title: Getting started with Rails app projects
section: rails
---

## Create a new Rails app project

To create a new Rails project, type `shopify create rails`. This will scaffold a new Rails app in a subdirectory.

```console
$ shopify create rails
? App Name
>
```

## Start a local development server

Once your app is created, you can work with it immediately by running `shopify serve` to start a local development server. Shopify App CLI uses [ngrok](https://ngrok.com) to create a tunnel. ngrok will choose a unique URL for you. The server will stay open until you type **Ctrl-C**.

```console
$ shopify serve
✓ ngrok tunnel running at https://example.ngrok.io
✓ writing .env file...
```

## Install your app on your development store

With the server running, open a new terminal window and run `shopify open` to open your app in your browser and install it on a development store.

```console
$ shopify open
```

For more information, consult the [Rails project command reference]({{ site.baseurl }}{% link app/rails/commands/index.md %}).

