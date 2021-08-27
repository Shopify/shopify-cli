# frozen_string_literal: true

module Extension
  module Models
    module ServerConfig
      class DevelopmentRenderer < Base
        include SmartProperties

        VALID_RENDERERS = [
          "@shopify/admin-ui-extensions",
          "@shopify/post-purchase-ui-extensions",
          "@shopify/checkout-ui-extensions",
        ]

        property! :name, accepts: VALID_RENDERERS
      end
    end
  end
end
