#!/bin/sh

# If we're not already in a shim environment but still tried to set up a shim, print out the re-installation warning
type __shopify_cli__ > /dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "The Shopify CLI is no longer available as a Git repository. It is now delivered as a package.
    Please visit https://shopify.github.io/shopify-app-cli for installation instructions."
fi
