# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class ServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
        ShopifyCli::Shopifolk.stubs(:check).returns(false)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(false)

        @api_key = "TEST"
        setup_temp_project(api_key: @api_key)
      end

      def test_implements_help
        refute_empty(Serve.help)
      end

      def test_uses_js_system_to_run_npm_or_yarn_serve_commands
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: Serve::YARN_SERVE_COMMAND, npm: Serve::NPM_SERVE_COMMAND)
          .returns(true)
          .once

        run_serve
      end

      def test_aborts_and_informs_the_user_when_serve_fails
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: Serve::YARN_SERVE_COMMAND, npm: Serve::NPM_SERVE_COMMAND)
          .returns(false)
          .once
        @context.expects(:abort).with(@context.message("serve.serve_failure_message"))

        run_serve
      end

      def test_uses_js_system_to_run_npm_or_yarn_serve_commands_with_shop_argument_for_first_party
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)

        serve_args = ["--shop=my-test-shop.myshopify.com", "--apiKey=#{@api_key}"]
        yarn_serve_command = Serve::YARN_SERVE_COMMAND + serve_args
        npm_serve_command = Serve::NPM_SERVE_COMMAND + %w(--) + serve_args
        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: yarn_serve_command, npm: npm_serve_command)
          .returns(true)
          .once

        run_serve
      end

      def test_raises_exception_if_shop_is_empty
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ExtensionProject.stubs(:reload)

        Extension.specifications.stubs(:valid?).returns(true)
        Extension.specifications.stubs(:[]).returns(DummySpecifications.build(
          identifier: "test-extension", surface: "admin"
        ))
        ExtensionProject.current.env.stubs(:shop).returns(" ")

        exception = assert_raises ShopifyCli::Abort do
          run_serve
        end
        assert_includes exception.message, @context.message("serve.serve_missing_information")
      end

      def test_raises_exception_if_api_key_is_empty
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ExtensionProject.stubs(:reload)

        Extension.specifications.stubs(:valid?).returns(true)
        Extension.specifications.stubs(:[]).returns(DummySpecifications.build(
          identifier: "test-extension", surface: "admin"
        ))
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
    end
  end
end
