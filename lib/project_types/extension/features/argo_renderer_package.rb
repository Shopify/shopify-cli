module Extension
  module Features
    class ArgoRendererPackage
      include SmartProperties

      ARGO_CHECKOUT = "@shopify/argo-checkout"
      ARGO_ADMIN = "@shopify/argo-admin"
      ARGO_POST_PURCHASE = "@shopify/argo-post-purchase"

      PACKAGE_NAMES = [
        ARGO_CHECKOUT,
        ARGO_ADMIN,
        ARGO_POST_PURCHASE,
      ].freeze

      property! :package_name, accepts: PACKAGE_NAMES
      property! :version, accepts: String

      class << self
        def from_npm_package(package)
          new(package_name: package.name, version: package.version)
        end
      end

      def checkout?
        package_name == ARGO_CHECKOUT
      end

      def admin?
        package_name == ARGO_ADMIN
      end
    end
  end
end
