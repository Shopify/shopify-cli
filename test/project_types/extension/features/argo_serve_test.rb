# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoServeTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        ShopifyCLI::ProjectType.load_type(:extension)
        super
      end

      def test_argo_serve_defers_to_js_system_when_shopifolk_check_is_false
        stub_package_manager
        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: admin_ui_extension_runtime,
          specification_handler: specification_handler,
          js_system: fake_js_system
        )

        argo_serve.expects(:validate_env!).once
        argo_serve.call
      end

      def test_argo_serve_abort_when_server_start_failed
        stub_package_manager
        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: admin_ui_extension_runtime,
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

      def test_forwards_resource_url
        ShopifyCLI::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCLI::Tasks::EnsureEnv.stubs(:call)
        ExtensionProject.stubs(:update_env_file)
        ExtensionProject.any_instance.expects(:resource_url).returns("/test").at_least_once

        js_system = mock
        js_system.expects(:call)
          .with do |_, config|
            assert_includes config.fetch(:yarn), "--resourceUrl=/test"
            assert_includes config.fetch(:npm), "--resourceUrl=/test"
          end
          .returns(true)

        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: checkout_ui_extension_runtime,
          specification_handler: specification_handler,
          js_system: js_system
        )

        argo_serve.call
      end

      def test_resource_url_is_used_if_given
        ShopifyCLI::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCLI::Tasks::EnsureEnv.stubs(:call)

        js_system = mock
        js_system.expects(:call)
          .with do |_, config|
            assert_includes config.fetch(:yarn), "--resourceUrl=/provided"
            assert_includes config.fetch(:npm), "--resourceUrl=/provided"
          end
          .returns(true)

        argo_serve = Features::ArgoServe.new(
          context: @context,
          argo_runtime: checkout_ui_extension_runtime,
          specification_handler: specification_handler,
          js_system: js_system,
          resource_url: "/provided"
        )

        argo_serve.call
      end

      private

      def admin_ui_extension_runtime
        Features::Runtimes::Admin.new
      end

      def checkout_ui_extension_runtime
        Features::Runtimes::CheckoutUiExtension.new
      end

      def specification_handler
        ExtensionTestHelpers.test_specifications["TEST_EXTENSION"]
      end

      def fake_js_system(success: true)
        proc { success }
      end

      def stub_ensure_env_check
        ShopifyCLI::Tasks::EnsureEnv.stubs(:call)
      end

      def stub_package_manager
        Tasks::FindPackageFromJson.expects(:call)
          .returns(Models::NpmPackage.new(name: "@shopify/admin-ui-extensions", version: "0.3.8"))
      end
    end
  end
end
