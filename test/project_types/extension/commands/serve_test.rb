# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def setup
        super
        stub_argo_enabled_shop
        api_key = "TEST"
        setup_temp_project(api_key: api_key)
        @argo_version = "0.0.1"
        serve_args = ["--shop=my-test-shop.myshopify.com", "--apiKey=#{api_key}", "--argoVersion=#{@argo_version}"]
        @yarn_serve_command = YARN_SERVE_COMMAND + serve_args
        @npm_serve_command = NPM_SERVE_COMMAND + %w(--) + serve_args
      end

      def test_implements_help
        ShopifyCli::ProjectType.load_type(:extension)
        ShopifyCli::Shopifolk.stubs(:check).returns(false)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(false)

        refute_empty(Serve.help)
      end

      def test_uses_js_system_to_run_npm_or_yarn_serve_commands
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: @yarn_serve_command, npm: @npm_serve_command)
          .returns(true)
          .once

        run_serve
      end

      def test_aborts_and_informs_the_user_when_serve_fails
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: @yarn_serve_command, npm: @npm_serve_command)
          .returns(false)
          .once
        @context.expects(:abort).with(@context.message("serve.serve_failure_message"))

        run_serve
      end

      def test_uses_js_system_to_run_npm_or_yarn_serve_commands_with_shop_argument_for_first_party
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: @yarn_serve_command, npm: @npm_serve_command)
          .returns(true)
          .once

        run_serve
      end

      def test_raises_exception_if_shop_is_empty
        ExtensionProject.stubs(:reload)

        ExtensionProject.current.env.stubs(:shop).returns(" ")

        exception = assert_raises ShopifyCli::Abort do
          run_serve
        end
        assert_includes exception.message, @context.message("serve.serve_missing_information")
      end

      def test_raises_exception_if_api_key_is_empty
        ExtensionProject.stubs(:reload)

        ExtensionProject.current.env.stubs(:api_key).returns(" ")

        exception = assert_raises ShopifyCli::Abort do
          run_serve
        end
        assert_includes exception.message, @context.message("serve.serve_missing_information")
      end

      private

      def run_serve(*args)
        Serve.ctx = @context
        Serve.call(args, "serve")
      end

      def stub_argo_enabled_shop
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        Extension::Features::Argo.any_instance.stubs(:extract_argo_renderer_version).returns("0.0.1")
      end
    end
  end
end
