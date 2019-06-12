**COMMAND**
**generate**
Generate code in your project for pages, calling the Billing API, and receiving webhooks. 

**USAGE**
shopify generate [subcommand] 

**SUBCOMMANDS**
page PAGENAME

billing

webhook WEBHOOK_NAME

**EXAMPLES**
shopify generate page onboarding
Generate a new page in your app with a URL route of pages/onboarding. All pages are contained in the pages directory.

shopify generate billing
Generate a new call to Shopify’s billing API by adding the necessary code to the project’s server.js file.

shopify generate webhook
Show a list of all available webhooks in your terminal.

shopify generate webhook PRODUCTS_CREATE
Generate and register a new webhook that will be called every time a new product is created on your store.
