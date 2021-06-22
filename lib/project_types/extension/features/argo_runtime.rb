module Extension
  module Features
    class ArgoRuntime
      include SmartProperties

      UI_EXTENSIONS_CHECKOUT_RUN = "@shopify/checkout-ui-extensions-run"
      UI_EXTENSIONS_ADMIN_RUN = "@shopify/admin-ui-extensions-run"

      ADMIN_RUN_FLAGS = [
        :api_key,
        :name,
        :port,
        :public_url,
        :renderer_version,
        :shop,
        :uuid,
      ]

      CHECKOUT_RUN_FLAGS = [
        :port,
        :public_url,
      ]

      property! :renderer, accepts: Models::NpmPackage
      property! :cli, accepts: Models::NpmPackage

      def supports?(flag)
        case cli
        when admin?
          ADMIN_RUN_FLAGS.include?(flag.to_sym)
        when checkout?
          CHECKOUT_RUN_FLAGS.include?(flag.to_sym)
        end
      end

      private

      def admin?
        ->(cli) { cli.name == UI_EXTENSIONS_ADMIN_RUN }
      end

      def checkout?
        ->(cli) { cli.name == UI_EXTENSIONS_CHECKOUT_RUN }
      end
    end
  end
end
