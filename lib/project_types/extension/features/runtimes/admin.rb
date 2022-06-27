require 'byebug'

module Extension
  module Features
    module Runtimes
      class Admin < Base
        ADMIN_UI_EXTENSIONS_RUN = "@shopify/admin-ui-extensions-run"
        PRODUCT_SUBSCRIPTION = "PRODUCT_SUBSCRIPTION"

        AVAILABLE_FLAGS = [
          :api_key,
          :name,
          :port,
          :public_url,
          :renderer_version,
          :resource_url,
          :shop,
          :uuid,
        ]

        def available_flags
          AVAILABLE_FLAGS
        end

        def active_runtime?(cli_package, identifier)
          return false if cli_package.nil?

          cli_package.name == ADMIN_UI_EXTENSIONS_RUN && identifier == PRODUCT_SUBSCRIPTION
        end
      end
    end
  end
end
