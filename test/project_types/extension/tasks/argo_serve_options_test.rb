# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class ArgoServeOptionsTest < MiniTest::Test
      include ExtensionTestHelpers::TestExtensionSetup
      include TestHelpers::FakeUI

      DEFAULT_PORT = 39351

      def test_serve_options_include_port_if_port_supported
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.11.0")
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--port=#{DEFAULT_PORT}")
        assert_includes(options.npm_serve_command, "--port=#{DEFAULT_PORT}")
      end

      def test_serve_options_include_api_key_when_required
        required_fields = [:api_key]
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.1.2-doesnt-matter")
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
          renderer_package: argo_admin, required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--apiKey=apikey")
        assert_includes(options.npm_serve_command, "--apiKey=apikey")
      end

      def test_serve_options_include_shop_when_required
        required_fields = [:shop]
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.1.2-doesnt-matter")
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
          renderer_package: argo_admin, required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--shop=my-test-shop.myshopify.com")
        assert_includes(options.npm_serve_command, "--shop=my-test-shop.myshopify.com")
      end

      def test_serve_options_include_argo_version_if_argo_version_supported
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.9.3")
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--argoVersion=0.1.2")
        assert_includes(options.npm_serve_command, "--argoVersion=0.1.2")
      end

      def test_public_url_is_included_if_public_url_supported
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.11.0")
        tunnel_url = "test.com"
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
          renderer_package: argo_admin, public_url: tunnel_url)

        assert_includes(options.yarn_serve_command, "--publicUrl=#{tunnel_url}")
        assert_includes(options.npm_serve_command, "--publicUrl=#{tunnel_url}")
      end

      def test_serve_options_include_uuid_if_uuid_supported
        cli_compatibility = setup_cli_compatibility(renderer_package: argo_admin, version: "0.11.0")
        registration_uuid = "dev-12345"
        ExtensionProject.any_instance.expects(:registration_uuid).returns(registration_uuid)
        options = Features::ArgoServeOptions.new(cli_compatibility: cli_compatibility, context: @context,
renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--uuid=#{registration_uuid}")
        assert_includes(options.npm_serve_command, "--uuid=#{registration_uuid}")
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

      def setup_cli_compatibility(renderer_package:, version:, cli_package_name: "@shopify/argo-admin-cli")
        installed_cli_package = Models::NpmPackage.new(name: cli_package_name, version: version)

        Features::ArgoCliCompatibility.new(renderer_package: renderer_package,
          installed_cli_package: installed_cli_package)
      end
    end
  end
end
