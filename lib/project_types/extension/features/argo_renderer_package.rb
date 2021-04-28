module Extension
  module Features
    class ArgoRendererPackage
      include SmartProperties

      ARGO_CHECKOUT = "@shopify/argo-checkout"
      ARGO_ADMIN = "@shopify/argo-admin"

      PACKAGE_NAMES = [
        ARGO_CHECKOUT,
        ARGO_ADMIN,
      ].freeze
      MINIMUM_ARGO_VERSION = "0.9.3".freeze

      property! :package_name, accepts: PACKAGE_NAMES
      property! :version, accepts: String

      def checkout?
        package_name == ARGO_CHECKOUT
      end

      def admin?
        package_name == ARGO_ADMIN
      end

      def supports_uuid_flag?
        return false if checkout?
        Gem::Version.new(version) > Gem::Version.new(MINIMUM_ARGO_VERSION)
      end
    end
  end
end
