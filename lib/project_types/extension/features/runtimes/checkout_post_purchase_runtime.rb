module Extension
  module Features
    module Runtimes
      class CheckoutPostPurchaseRuntime < ArgoRuntime
        CLI_PACKAGE_NAME = "@shopify/checkout-ui-extensions-run"

        AVAILABLE_FLAGS = [
          :port,
          :public_url,
        ]

        def cli_package
          CLI_PACKAGE_NAME
        end

        def available_flags
          AVAILABLE_FLAGS
        end
      end
    end
  end
end
