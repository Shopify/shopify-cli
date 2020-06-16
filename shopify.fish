#!/usr/bin/env fish
# vi: ft=fish

# If we're not already in a shim environment but still tried to set up a shim, print out the re-installation warning
type -t shopify > /dev/null 2>&1
if [ $status != "0" ]
  echo "This version of Shopify App CLI is no longer supported. You'll need to upgrade to continue using it, this process typically takes a few minutes.
    Please visit https://shopify.github.io/shopify-app-cli/upgrade/ for complete instructions."
end
