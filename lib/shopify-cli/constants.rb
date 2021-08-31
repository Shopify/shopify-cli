module ShopifyCli
  module Constants
    module EnvironmentVariables
      # When true the CLI points to a local instance of
      # the partners dashboard and identity.
      LOCAL_PARTNERS = "SHOPIFY_APP_CLI_LOCAL_PARTNERS"

      # Set to true when running tests.
      RUNNING_TESTS = "RUNNING_SHOPIFY_CLI_TESTS"
    end

    module Identity
      CLIENT_ID_DEV = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
      CLIENT_ID = "e5380e02-312a-7408-5718-e07017e9cf52"
    end
  end
end
