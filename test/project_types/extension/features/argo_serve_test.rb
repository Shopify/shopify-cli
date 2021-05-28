# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        ShopifyCli::ProjectType.load_type(:extension)
        super
      end

      def test_argo_serve_defers_to_js_system_when_shopifolk_check_is_false
        cli = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")
        renderer = Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.0.1")
        argo_runtime = Features::ArgoRuntime.new(cli: cli, renderer: renderer)
        specification_handler = ExtensionTestHelpers.test_specifications["TEST_EXTENSION"]

        ShopifyCli::Shopifolk.stubs(:check).returns(false)

        argo_serve = Features::ArgoServe.new(context: @context, argo_runtime: argo_runtime,
          specification_handler: specification_handler)

        Tasks::FindNpmPackages.expects(:exactly_one_of).returns(ShopifyCli::Result.success(renderer))
        argo_serve.expects(:validate_env!).once
        argo_serve.expects(:call_js_system).returns(true).once
        argo_serve.call
      end

      def test_argo_serve_defers_to_js_system_for_argo_admin_beta
        cli = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")
        renderer = Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.0.1")
        argo_runtime = Features::ArgoRuntime.new(cli: cli, renderer: renderer)

        specification = Extension::Models::Specification.new(
          {
            identifier: "test",
            features: {
              argo: {
                surface: "admin",
                git_template: "https://github.com/Shopify/argo-admin.git",
                renderer_package_name: "@shopify/argo-admin",
                required_fields: [:shop, :api_key],
                required_shop_beta_flags: [:argo_admin_beta],
              },
            },
          }
        )
        specification_handler = Extension::Models::SpecificationHandlers::Default.new(specification)

        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)

        argo_serve = Features::ArgoServe.new(context: @context, argo_runtime: argo_runtime,
          specification_handler: specification_handler)

        Tasks::FindNpmPackages.expects(:exactly_one_of).returns(ShopifyCli::Result.success(renderer))

        argo_serve.expects(:call_js_system).returns(true).once
        argo_serve.call
      end
    end
  end
end
