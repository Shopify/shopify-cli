module Extension
  module Features
    module Runtimes
      class Admin < Base
        ADMIN_UI_EXTENSIONS_RUN = "@shopify/admin-ui-extensions-run"
        PRODUCT_SUBSCRIPTION = "PRODUCT_SUBSCRIPTION"
        HACKDAYS_30 = "HACK_DAYS_30_ARGO_APP_BRIDGE"

        AVAILABLE_FLAGS = [
          :api_key,
          :name,
          :port,
          :public_url,
          :renderer_version,
          :shop,
          :uuid,
        ]

        def available_flags
          AVAILABLE_FLAGS
        end

        def valid_identifier(identifier) {
          identifier == PRODUCT_SUBSCRIPTION || identifier == HACKDAYS_30
        }

        def active_runtime?(cli_package, identifier)
          cli_package.name == ADMIN_UI_EXTENSIONS_RUN && valid_identifier(identifier)
        end
      end
    end
  end
end
