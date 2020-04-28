---
title: Node app projects
section: node
---

## Getting started

1. To create a new Node project, type `shopify create node`. This will scaffold a new Node.js app in a subdirectory.

    ```console
    $ shopify create node
    ? App Name
    >
    ```

2. Once your app is created, you can work with it immediately by typing `shopify serve` to start a local development server. Shopify App CLI uses [ngrok](https://ngrok.com) to create a tunnel. ngrok will choose a unique URL for you. The server will stay open until you type **Ctrl-C**.

    ```console
    $ shopify serve
    ✓ ngrok tunnel running at https://example.ngrok.io
    ✓ writing .env file...
    ```

3. With the server running, open a new terminal window and type `shopify open` to open your app in your browser and install it on a development store.

    ```console
    $ shopify open
    ```

For more information, look at the [command reference]({{ site.baseurl }}{% link app/node/commands/index.md %}).
