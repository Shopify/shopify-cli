module Extension
  module Features
    module Runtimes
      class CheckoutPostPurchase < Base
        CHECKOUT_UI_EXTENSIONS_RUN = "@shopify/checkout-ui-extensions-run"
        CHECKOUT_POST_PURCHASE = "CHECKOUT_POST_PURCHASE"

        AVAILABLE_FLAGS = [
          :port,
          :public_url,
        ]

        def available_flags
          AVAILABLE_FLAGS
        end

        def active_runtime?(cli_package, identifier)
          cli_package.name == CHECKOUT_UI_EXTENSIONS_RUN && identifier == CHECKOUT_POST_PURCHASE
        end
      end
    end
  end
end
