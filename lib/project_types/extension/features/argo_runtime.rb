module Extension
  module Features
    class ArgoRuntime
      include SmartProperties

      ARGO_RUN_PACKAGE_NAME = "@shopify/argo-run"
      ARGO_ADMIN_CLI_PACKAGE_NAME = "@shopify/argo-admin-cli"

      ARGO_RUN_0_4_0 = Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.4.0")
      ARGO_ADMIN_CLI_0_9_0 = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.0")
      ARGO_ADMIN_CLI_0_9_3 = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.3")
      ARGO_ADMIN_CLI_0_11_0 = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")

      property! :renderer, accepts: Models::NpmPackage
      property! :cli, accepts: Models::NpmPackage

      def accepts_port?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_11_0
        when checkout?
          cli >= ARGO_RUN_0_4_0
        end
      end

      def accepts_tunnel_url?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_11_0
        when checkout?
          cli >= ARGO_RUN_0_4_0
        end
      end

      def accepts_uuid?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_11_0
        else
          false
        end
      end

      def accepts_argo_version?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_9_3
        else
          false
        end
      end

      def accepts_shop?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_11_0
        else
          false
        end
      end

      def accepts_api_key?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_11_0
        else
          false
        end
      end

      def accepts_name?
        case cli
        when admin?
          cli >= ARGO_ADMIN_CLI_0_9_0
        else
          false
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
