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

      def test_argo_minimum_version_supports_uuid_flag
        skip("Passing the a UUID to the Argo Webpack server is currently not supported")

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

      def test_instantiation_from_package_manager_output
        argo_renderer_package = ArgoRendererPackage.from_package_manager(
          package_manager_output,
        )

        assert_kind_of(ArgoRendererPackage, argo_renderer_package)
        assert_equal "0.9.1", argo_renderer_package.version
        assert_equal "@shopify/argo-post-purchase", argo_renderer_package.package_name
      end

      def test_instantiation_from_npm_output_using_depth_1_when_listing_packages
        argo_renderer_package = ArgoRendererPackage.from_package_manager(
          npm_output_with_depth_1,
        )

        assert_kind_of(ArgoRendererPackage, argo_renderer_package)
        assert_equal "0.10.1", argo_renderer_package.version
        assert_equal "@shopify/argo-admin", argo_renderer_package.package_name
      end

      def test_raises_an_error_when_no_renderer_package_was_found
        assert_raises Extension::PackageNotFound do
          ArgoRendererPackage.from_package_manager(
            malformed_package_manager_output_without_renderer,
          )
        end
      end

      def test_raises_an_error_when_no_exact_version_for_renderer_was_specified
        assert_raises Extension::PackageNotFound do
          ArgoRendererPackage.from_package_manager(
            malformed_package_manager_output_with_version_range,
          )
        end
      end

      private

      def package_manager_output
        <<~NPM
          argo-checkout-template@0.1.0 /Users/t6d/src/local/cli-specification-experiment/2021-04-30_post_purchase_test
          ├── @shopify/argo-post-purchase-react@0.9.3
          ├── @shopify/argo-post-purchase@0.9.1
          └── react@17.0.1
        NPM
      end

      def malformed_package_manager_output_without_renderer
        <<~NPM
          argo-checkout-template@0.1.0 /Users/t6d/src/local/cli-specification-experiment/2021-04-30_post_purchase_test
          ├── @shopify/argo-post-purchase-react@0.9.3
          └── react@17.0.1
        NPM
      end

      def malformed_package_manager_output_with_version_range
        <<~NPM
          argo-checkout-template@0.1.0 /Users/t6d/src/local/cli-specification-experiment/2021-04-30_post_purchase_test
          ├── @shopify/argo-post-purchase-react@0.9.3
          ├── @shopify/argo-post-purchase@^0.9.1
          └── react@17.0.1
        NPM
      end

      def npm_output_with_depth_1
        <<~NPM
          shopify-app-extension-template@0.1.0 /Users/trishta/src/extensions/test_dynamic_renderer_admin
          ├─┬ @shopify/argo-admin-react@0.10.1
          │ ├── @remote-ui/react@4.0.2
          │ ├── @shopify/argo-admin@0.10.1
          │ └── react@17.0.2 deduped
          └─┬ react@17.0.2
            ├── loose-envify@1.4.0
            └── object-assign@4.1.1
        NPM
      end
    end
  end
end
