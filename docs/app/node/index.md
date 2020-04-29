---
title: Getting started with Node.js app projects
section: node
toc: false
---

## Create a new Node.js app project

To create a new Node.js project, type `shopify create node`. This will scaffold a new Node.js app in a subdirectory.

```console
$ shopify create node
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

For more information, consult the [Node.js project command reference]({{ site.baseurl }}{% link app/node/commands/index.md %}).
