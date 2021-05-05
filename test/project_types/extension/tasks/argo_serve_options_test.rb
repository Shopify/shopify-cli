# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class ArgoServeOptionsTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup
      include TestHelpers::FakeUI

      DEFAULT_PORT = 39351

      def test_serve_options_include_port_when_no_port_given
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--port=#{DEFAULT_PORT}")
        assert_includes(options.npm_serve_command, "--port=#{DEFAULT_PORT}")
      end

      def test_serve_options_use_custom_port_if_one_is_given
        custom_port = 12345
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin, port: custom_port)

        assert_includes(options.yarn_serve_command, "--port=#{custom_port}")
        assert_includes(options.npm_serve_command, "--port=#{custom_port}")
      end

      def test_default_serve_options_include_api_key_when_required
        required_fields = [:api_key]
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin,
          required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--apiKey=apikey")
        assert_includes(options.npm_serve_command, "--apiKey=apikey")
      end

      def test_default_serve_options_include_shop_when_required
        required_fields = [:shop]

        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin,
          required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--shop=my-test-shop.myshopify.com")
        assert_includes(options.npm_serve_command, "--shop=my-test-shop.myshopify.com")
      end

      def test_serve_options_include_argo_version_if_renderer_package_is_admin
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--argoVersion=0.1.2")
        assert_includes(options.npm_serve_command, "--argoVersion=0.1.2")
      end

      def test_public_url_is_included_if_one_is_given
        tunnel_url = "test.com"
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin,
        public_url: tunnel_url)

        assert_includes(options.yarn_serve_command, "--publicUrl=#{tunnel_url}")
        assert_includes(options.npm_serve_command, "--publicUrl=#{tunnel_url}")
      end

      def test_public_url_is_not_included_if_one_not_given
        options = Features::ArgoServeOptions.new(context: @context, renderer_package: argo_admin)

        refute_includes(options.yarn_serve_command, "--publicUrl=test.com")
        refute_includes(options.npm_serve_command, "--publicUrl=test.com")
      end

      private

      def argo_renderer_package(package_name:, version: "0.1.2")
        Features::ArgoRendererPackage.new(
          package_name: package_name,
          version: version
        )
      end

      def argo_admin
        argo_renderer_package(package_name: "@shopify/argo-admin")
      end
    end
  end
end
