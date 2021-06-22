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
        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: argo_runtime,
          specification_handler: specification_handler,
          js_system: fake_js_system
        )

        argo_serve.expects(:validate_env!).once
        argo_serve.call
      end

      def test_argo_serve_abort_when_server_start_failed
        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: argo_runtime,
          specification_handler: specification_handler,
          js_system: fake_js_system(success: false)
        )

        argo_serve.expects(:validate_env!).once
        error = assert_raises CLI::Kit::Abort do
          argo_serve.call
        end
        assert_equal(
          format("{{x}} %s", @context.message("serve.serve_failure_message")),
          error.message
        )
      end

      private

      def argo_runtime
        Features::ArgoRuntime.new(cli: cli, renderer: renderer)
      end

      def cli
        Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")
      end

      def renderer
        Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.0.1")
      end

      def specification_handler
        ExtensionTestHelpers.test_specifications["TEST_EXTENSION"]
      end

      def fake_js_system(success: true)
        proc { success }
      end
    end
  end
end
