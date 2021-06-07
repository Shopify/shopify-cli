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

        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: argo_runtime,
          specification_handler: specification_handler
        )

        Tasks::FindNpmPackages.expects(:exactly_one_of).returns(ShopifyCli::Result.success(renderer))
        argo_serve.expects(:validate_env!).once
        argo_serve.expects(:call_js_system).returns(true).once
        argo_serve.call
      end
    end
  end
end
