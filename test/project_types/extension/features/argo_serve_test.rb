# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      ARGO_ADMIN_TEMPLATE = "https://github.com/Shopify/argo-admin.git"

      def test_argo_serve_defers_to_js_system
        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")
        npm_package = Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.0.1")
        renderer_package = Features::ArgoRendererPackage.from_npm_package(npm_package)
        cli_compatibility = Features::ArgoCliCompatibility.new(installed_cli_package: installed_cli_package,
          renderer_package: renderer_package)
        argo_serve = Features::ArgoServe.new(context: @context, cli_compatibility: cli_compatibility,
          specification_handler: specification_handler)

        Tasks::FindNpmPackages.expects(:exactly_one_of).returns(ShopifyCli::Result.success(npm_package))
        argo_serve.expects(:validate_env!).once
        argo_serve.expects(:call_js_system).returns(true).once
        argo_serve.call
      end

      private

      def specification
        Extension::Models::Specification.new(
          {
            identifier: "test",
            features: {
              argo: {
                surface: "admin",
                git_template: ARGO_ADMIN_TEMPLATE,
                renderer_package_name: "@shopify/argo-admin",
                required_fields: [],
                required_shop_beta_flags: [],
              },
            },
          }
        )
      end

      def specification_handler
        Extension::Models::SpecificationHandlers::Default.new(specification)
      end
    end
  end
end
