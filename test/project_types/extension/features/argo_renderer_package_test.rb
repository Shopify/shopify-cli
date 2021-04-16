require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRendererPackageTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

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

      def test_argo_minimum_version_supports_uuid_flag
        uuid_supported = Features::ArgoRendererPackage.new(
          package_name: Features::ArgoRendererPackage::ARGO_ADMIN,
          version: "0.9.4"
        )
        uuid_unsupported = Features::ArgoRendererPackage.new(
          package_name: Features::ArgoRendererPackage::ARGO_ADMIN,
          version: "0.1.2"
        )
        assert_predicate(uuid_supported, :supports_uuid_flag?)
        refute_predicate(uuid_unsupported, :supports_uuid_flag?)
      end
    end
  end
end
