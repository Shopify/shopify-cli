# frozen_string_literal: true

require "shopify_cli"

module Extension
  module Models
    class DevelopmentServerRequirements
      SUPPORTED_EXTENSION_TYPES = [
        "checkout_ui_extension",
        "checkout_post_purchase",
        "product_subscription",
        "web_pixel_extension",
        "pos_ui_extension",
      ]

      class << self
        def supported?(type)
          if type_supported?(type) && beta_enabled?
            return true if binary_installed?
            warn_about_missing_binary
          end

          false
        end

        def beta_enabled?
          ShopifyCLI::Feature.enabled?(:extension_server_beta)
        end

        def type_supported?(type)
          SUPPORTED_EXTENSION_TYPES.include?(type.downcase)
        end

        private

        def binary_installed?
          Models::DevelopmentServer.new.executable_installed?
        end

        def warn_about_missing_binary
          CLI::UI::Frame.open(message("errors.development_server_binary_not_found.title"), color: :yellow) do
            context.puts(message("errors.development_server_binary_not_found.message"))
          end
        end

        def message(key)
          context.message(key)
        end

        def context
          @context ||= ShopifyCLI::Context.new
        end
      end
    end
  end
end
