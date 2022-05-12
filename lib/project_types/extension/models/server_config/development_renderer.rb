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
          "@shopify/retail-ui-extensions",
        ]

        property :name, accepts: VALID_RENDERERS, required: false
        property :version, accepts: String, default: "latest", required: false

        def self.find(type)
          case type.downcase
          when "product_subscription"
            new(name: "@shopify/admin-ui-extensions", version: "^1.0.1")
          when "checkout_ui_extension"
            new(name: "@shopify/checkout-ui-extensions", version: "^0.15.0")
          when "checkout_post_purchase"
            new(name: "@shopify/post-purchase-ui-extensions", version: "^0.13.2")
          when "pos_ui_extension"
            new(name: "@shopify/retail-ui-extensions", version: "^0.1.0")
          when "beacon_extension"
            nil
          else
            raise ArgumentError, "Unknown extension type: #{type}"
          end
        end
      end
    end
  end
end
