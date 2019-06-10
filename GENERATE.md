**generate**
Generate pages, billing, and webhooks in your app project.

**USAGE**
shopify generate [subcommand] 

**COMMANDS**
page PAGENAME
>>aliases: p

billing
>>aliases: c

webhook WEBHOOKNAME
>>aliases: o


**EXAMPLES**
shopify generate page onboarding
Generate a new page with routing named "onboarding"

shopify generate billing
Generate a new call to the billing api

shopify generate webhook products-create
Generate and register a new webhook to listen for new products being created
