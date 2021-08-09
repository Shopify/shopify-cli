module Extension
  module Features
    module Runtimes
      class CheckoutUiExtension < Base
        CHECKOUT_UI_EXTENSIONS_RUN = "@shopify/checkout-ui-extensions-run"

        IDENTIFIERS = [
          "checkout_argo_extension",
          "checkout_ui_extension",
        ]

        AVAILABLE_FLAGS = [
          :port,
          :public_url,
          :resource_url,
          :shop,
        ]

        def available_flags
          AVAILABLE_FLAGS
        end

        def active_runtime?(cli_package, identifier)
          cli_package.name == CHECKOUT_UI_EXTENSIONS_RUN && IDENTIFIERS.include?(identifier)
        end
      end
    end
  end
end
