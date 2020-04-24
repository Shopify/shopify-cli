---
title: Node.js app projects
section: node
---

## Node.js app projects

To create a Node project, type `shopify create node`.

Once you have created your project, the following commands are available while working in the project directory.

### deploy

Deploy the current Node project to a hosting service. [Heroku](https://www.heroku.com) is currently the only option, 
but more will be added in the future.

- `shopify deploy heroku`: Deploy the current Node project to Heroku 

### generate

Generate code in your app project. Supports generating new pages, new billing API calls, or new webhooks.

- `shopify generate page` generates a new page in your project.
- `shopify generate billing` generates a new billing API call.
- `shopify generate webhook` generates a new webhook.

### open

Open your local development app in the default browser.

- `shopify open`

### populate
Populate your Shopify development store with example products, customers, or orders.

- `shopify populate products`
- `shopify populate customers`
- `shopify populate draftorders`

### serve
Start a local development node server for your project, as well as a public [ngrok](https://ngrok.com/) tunnel to your 
localhost.

- `shopify serve`

### tunnel
Start or stop an http tunnel to your local development app using ngrok.

- `shopify tunnel auth` 
- `shopify tunnel start` starts the ngrok tunnel for your app
- `shopify tunnel stop` stops the ngrok tunnel for your app
