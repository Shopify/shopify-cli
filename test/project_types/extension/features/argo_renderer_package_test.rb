require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRendererPackageTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type("extension")
      end

      def test_checkout_is_returned_for_checkout_package
        argo_renderer_package = Features::ArgoRendererPackage.new(
          package_name: Features::ArgoRendererPackage::ARGO_CHECKOUT,
          version: "1.2.3"
        )
        assert_predicate(argo_renderer_package, :checkout?)
      end

      def test_admin_is_returned_for_admin_package
        argo_renderer_package = Features::ArgoRendererPackage.new(
          package_name: Features::ArgoRendererPackage::ARGO_ADMIN,
          version: "1.2.3"
        )
        assert_predicate(argo_renderer_package, :admin?)
      end

      def test_instantiation_from_npm_package
        npm_package = Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.3")
        argo_renderer_package = ArgoRendererPackage.from_npm_package(npm_package)

        assert_predicate(argo_renderer_package, :admin?)
        assert_equal("@shopify/argo-admin", argo_renderer_package.package_name)
        assert_equal("0.9.3", argo_renderer_package.version)
      end
    end
  end
end
