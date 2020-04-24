---
title: Rails app projects
section: rails
---

## Rails app projects

To create a Ruby on Rails project, type `shopify create rails`.

Once you have created your project, the following commands are available while working in the project directory.

### deploy

Deploy the current Rails project to a hosting service. [Heroku](https://www.heroku.com) is currently the only option, 
but more will be added in the future.

- `shopify deploy heroku`: Deploy the current Rails project to Heroku 

### generate

Generate code in your app project. Supports generating new webhooks.

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

- `shopify tunnel auth` writes an ngrok auth token to `~/.ngrok2/ngrok.yml` to allow connecting with an ngrok account.
  [Visit the ngrok site to sign up](https://dashboard.ngrok.com/signup)
- `shopify tunnel start` starts the ngrok tunnel for your app
- `shopify tunnel stop` stops the ngrok tunnel for your app
