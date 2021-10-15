module ShopifyCLI
  module Constants
    module Paths
      ROOT = File.expand_path("../..", __dir__)
    end

    module StoreKeys
      LAST_MIGRATION_DATE = :last_migration_date
      ANALYTICS_ENABLED = :analytics_enabled
    end

    module Bugsnag
      API_KEY = "773b0c801eb40c20d8928be5b7c739bd"
    end

    module Config
      module Sections
        module Analytics
          NAME = "analytics"
          module Fields
            ENABLED = "enabled"
          end
        end
      end
    end

    module EnvironmentVariables
      STACKTRACE = "SHOPIFY_CLI_STACKTRACE"

      # When true the CLI points to a local instance of
      # the partners dashboard and identity.
      LOCAL_PARTNERS = "SHOPIFY_APP_CLI_LOCAL_PARTNERS"

      # When true the CLI points to a spin instance of spin
      SPIN_PARTNERS = "SPIN_PARTNERS_SERVICE_FQDN"
      SPIN_INSTANCE_FQDN = "SPIN_INSTANCE_FQDN"
      SPIN_IDENTITY_SERVICE_FQDN = "SPIN_IDENTITY_SERVICE_FQDN"
      SPIN_WORKSPACE = "SPIN_WORKSPACE"
      SPIN_NAMESPACE = "SPIN_NAMESPACE"
      SPIN_HOST = "SPIN_HOST"

      # Environments
      TEST = "SHOPIFY_CLI_TEST"
      ACCEPTANCE_TEST = "SHOPIFY_CLI_ACCEPTANCE_TEST"
      DEVELOPMENT = "SHOPIFY_CLI_DEVELOPMENT"

      # Monorail
      MONORAIL_REAL_EVENTS = "MONORAIL_REAL_EVENTS"
    end

    module Identity
      CLIENT_ID_DEV = "e5380e02-312a-7408-5718-e07017e9cf52"
      CLIENT_ID = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
    end

    module Links
      NEW_ISSUE = "https://github.com/Shopify/shopify-cli/issues/new"
    end
  end
end
