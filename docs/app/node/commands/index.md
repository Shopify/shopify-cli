---
title: Node.js app project command reference
section: node
---

## `deploy`

Deploy the current Node.js app to a hosting service. Currently, the only option is [Heroku](https://www.heroku.com).

```console
$ shopify deploy heroku
```

## `open`

Open your local development app in your default browser.

```console
$ shopify open
```

## `populate`

Add example data to your development store. This is useful for testing your app’s behavior. You can create the following types of example store records:

- Products
- Customers
- Orders

```console
$ shopify populate products
$ shopify populate customers
$ shopify populate draftorders
```

By default, the `populate` command adds 5 records. Use the `--count` option to specify a different number:

```console
$ shopify populate products --count 10
```

## `serve`

Start a local development server for your project, as well as a public [ngrok](https://ngrok.com/) tunnel to your localhost.

```console
$ shopify serve
```

## `tunnel`

Control an HTTP tunnel to your local development app using [ngrok](https://ngrok.com). With the `tunnel` command you can authenticate with ngrok and start or stop the tunnel. (Note that the `serve` command will automatically run `tunnel start` for you.)

To authenticate with ngrok, you need an authentication token. You can find it in [your ngrok dashboard](https://dashboard.ngrok.com/auth/your-authtoken). Copy your token and use it with the `tunnel auth` command:

```console
$ shopify tunnel auth <token>
```

This will write your ngrok auth token to `~/.ngrok2/ngrok.yml`. To learn more about ngrok configuration, [consult ngrok’s documentation](https://ngrok.com/docs#config).

To start an ngrok tunnel to your app in your localhost development environment:

```console
$ shopify tunnel start
```

To stop the running ngrok tunnel:

```console
$ shopify tunnel stop
```
