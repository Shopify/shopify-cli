# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Models
    class DevelopmentServerRequirements
      SUPPORTED_EXTENSION_TYPES = [
        "checkout_ui_extension",
      ]

      def self.supported?(type)
        return false unless SUPPORTED_EXTENSION_TYPES.include?(type.downcase)
        ShopifyCLI::Shopifolk.check && ShopifyCLI::Feature.enabled?(:extension_server_beta)
      end
    end
  end
end
