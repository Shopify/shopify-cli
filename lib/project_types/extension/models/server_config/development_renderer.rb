# typed: ignore
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

        def self.find(type)
          case type.downcase
          when "product_subscription"
            new(name: "@shopify/admin-ui-extensions")
          when "checkout_ui_extension"
            new(name: "@shopify/checkout-ui-extensions")
          when "checkout_post_purchase"
            new(name: "@shopify/post-purchase-ui-extensions")
          end
        end
      end
    end
  end
end
