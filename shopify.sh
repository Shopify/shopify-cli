#!/bin/sh

# If we're not already in a shim environment but still tried to set up a shim, print out the re-installation warning
typeset -f shopify > /dev/null 2>&1
if [ "$?" != "0" ]; then
  echo "This version of Shopify CLI is no longer supported. You’ll need to migrate to the new CLI version to continue.

Please visit this page for complete instructions:
  https://shopify.dev/tools/cli/troubleshooting#migrate-from-a-legacy-version
"
fi
