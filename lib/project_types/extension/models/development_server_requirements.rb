# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Models
    class DevelopmentServerRequirements
      SUPPORTED_EXTENSION_TYPES = [
        "checkout_ui_extension",
      ]

      UNIX_NAME = "shopify-extensions"
      WINDOWS_NAME = "shopify-extensions.exe"

      class << self
        def supported?(type)
          binary_installed? && type_supported?(type) && beta_enabled?
        end

        private

        def binary_installed?
          Models::DevelopmentServer.new.executable_installed?
        end

        def type_supported?(type)
          SUPPORTED_EXTENSION_TYPES.include?(type.downcase)
        end

        def beta_enabled?
          ShopifyCLI::Shopifolk.check && ShopifyCLI::Feature.enabled?(:extension_server_beta)
        end
      end
    end
  end
end
