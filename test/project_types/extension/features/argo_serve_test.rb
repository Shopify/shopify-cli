# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoServeTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TempProjectSetup

      def setup
        super
        @yarn_serve_command = ArgoServe::YARN_SERVE_COMMAND
        @npm_serve_command = ArgoServe::NPM_SERVE_COMMAND + %w(--)
      end

      def test_commands_called_with_no_args_when_no_required_fields
        stub_argo_enabled_shop(api_key: "123")
        specification = {
          identifier: "test",
          features: {
            argo: {
              surface: "checkout",
              git_template: "https://github.com/Shopify/argo-checkout.git",
              renderer_package_name: "@shopify/argo-checkout",
            },
          },
        }
        dummy_specification = Extension::Models::Specification.new(specification)
        dummy_handler = Extension::Models::SpecificationHandlers::Default.new(dummy_specification)
        Extension::Features::Argo.any_instance.stubs(:extract_argo_renderer_version).returns("0.0.1")

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: @yarn_serve_command, npm: @npm_serve_command)
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      def test_commands_called_with_required_args_when_required_fields_present
        specification = {
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
        dummy_specification = Extension::Models::Specification.new(specification)
        dummy_handler = Extension::Models::SpecificationHandlers::Default.new(dummy_specification)
        api_key = "123"
        stub_argo_enabled_shop(api_key: api_key)

        serve_args = ["--shop=my-test-shop.myshopify.com", "--apiKey=#{api_key}", "--argoVersion=0.0.1"]
        yarn_with_args = @yarn_serve_command + serve_args
        npm_with_args = @npm_serve_command + serve_args

        ShopifyCli::JsSystem.any_instance
          .expects(:call)
          .with(yarn: yarn_with_args, npm: npm_with_args)
          .returns(true)
          .once
        ArgoServe.new(specification_handler: dummy_handler, context: @context).call
      end

      private

      def stub_argo_enabled_shop(api_key:)
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Feature.stubs(:enabled?).with(:argo_admin_beta).returns(true)
        ShopifyCli::Tasks::EnsureEnv.stubs(:call)
        ShopifyCli::Tasks::EnsureDevStore.stubs(:call)
        Extension::Features::Argo.any_instance.stubs(:extract_argo_renderer_version).returns("0.0.1")
        setup_temp_project(api_key: api_key)
      end
    end
  end
end
