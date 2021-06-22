module Extension
  module Features
    class ArgoRuntime
      include SmartProperties

      ARGO_RUN_PACKAGE_NAME = "@shopify/argo-run"
      ARGO_ADMIN_CLI_PACKAGE_NAME = "@shopify/argo-admin-cli"

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
        ->(cli) { cli.name == ARGO_ADMIN_CLI_PACKAGE_NAME }
      end

      def checkout?
        ->(cli) { cli.name == ARGO_RUN_PACKAGE_NAME }
      end
    end
  end
end
