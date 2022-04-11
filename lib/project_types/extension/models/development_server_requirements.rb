# frozen_string_literal: true

require "shopify_cli"

module Extension
  module Models
    class DevelopmentServerRequirements
      SUPPORTED_EXTENSION_TYPES = [
        "checkout_ui_extension",
        "checkout_post_purchase",
        "product_subscription",
        "beacon_extension",
      ]

      class << self
        def supported?(type)
          binary_installed? && type_supported?(type) && type_enabled?(type)
        end

        def beta_enabled?
          ShopifyCLI::Feature.enabled?(:extension_server_beta)
        end

        def type_supported?(type)
          SUPPORTED_EXTENSION_TYPES.include?(type.downcase)
        end

        # Some types are enabled unconditionally; others require beta_enabled
        def type_enabled?(type)
          beta_enabled? || "checkout_ui_extension" == type.downcase
        end

        private

        def binary_installed?
          Models::DevelopmentServer.new.executable_installed?
        end

        def context
          @context ||= ShopifyCLI::Context.new
        end
      end
    end
  end
end
