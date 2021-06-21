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
        argo_runtime = setup_argo_runtime(renderer_package: argo_admin, version: "0.11.0")
        options = Features::ArgoServeOptions.new(argo_runtime: argo_runtime, context: @context,
renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--port=#{DEFAULT_PORT}")
        assert_includes(options.npm_serve_command, "--port=#{DEFAULT_PORT}")
      end

      def test_serve_options_include_api_key_when_required
        required_fields = [:api_key]
        argo_runtime = setup_argo_runtime(
          renderer_package: argo_admin,
          version: "0.11.0",
        )

        options = Features::ArgoServeOptions.new(argo_runtime: argo_runtime, context: @context,
          renderer_package: argo_admin, required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--apiKey=apikey")
        assert_includes(options.npm_serve_command, "--apiKey=apikey")
      end

      def test_serve_options_include_shop_when_required
        required_fields = [:shop]
        argo_runtime = setup_argo_runtime(
          renderer_package: argo_admin,
          version: "0.11.0",
        )

        options = Features::ArgoServeOptions.new(argo_runtime: argo_runtime, context: @context,
          renderer_package: argo_admin, required_fields: required_fields)

        assert_includes(options.yarn_serve_command, "--store=my-test-shop.myshopify.com")
        assert_includes(options.npm_serve_command, "--store=my-test-shop.myshopify.com")
      end

      def test_serve_options_include_argo_version_if_argo_version_supported
        argo_runtime = setup_argo_runtime(renderer_package: argo_admin("0.9.3"), version: "0.9.3")
        options = Features::ArgoServeOptions.new(
          argo_runtime: argo_runtime,
          context: @context,
          renderer_package: argo_admin("0.9.4")
        )
        assert_includes(options.yarn_serve_command, "--argoVersion=0.9.4")
        assert_includes(options.npm_serve_command, "--argoVersion=0.9.4")
      end

      def test_public_url_is_included_if_public_url_supported
        argo_runtime = setup_argo_runtime(renderer_package: argo_admin, version: "0.11.0")
        tunnel_url = "test.com"
        options = Features::ArgoServeOptions.new(argo_runtime: argo_runtime, context: @context,
          renderer_package: argo_admin, public_url: tunnel_url)

        assert_includes(options.yarn_serve_command, "--publicUrl=#{tunnel_url}")
        assert_includes(options.npm_serve_command, "--publicUrl=#{tunnel_url}")
      end

      def test_serve_options_include_uuid_if_uuid_supported
        argo_runtime = setup_argo_runtime(renderer_package: argo_admin, version: "0.11.0")
        registration_uuid = "dev-12345"
        ExtensionProject.any_instance.expects(:registration_uuid).returns(registration_uuid)
        options = Features::ArgoServeOptions.new(argo_runtime: argo_runtime, context: @context,
renderer_package: argo_admin)

        assert_includes(options.yarn_serve_command, "--uuid=#{registration_uuid}")
        assert_includes(options.npm_serve_command, "--uuid=#{registration_uuid}")
      end

      def test_serve_options_include_name_if_name_supported
        argo_runtime = setup_argo_runtime(renderer_package: argo_admin, version: "0.9.0")
        extension_title = "my test extension"
        ExtensionProject.any_instance.expects(:title).returns(extension_title)
        options = Features::ArgoServeOptions.new(
          argo_runtime: argo_runtime, context: @context,
          renderer_package: argo_admin
        )

        assert_includes(options.yarn_serve_command, "--name=#{extension_title}")
        assert_includes(options.npm_serve_command, "--name=#{extension_title}")
      end

      private

      def argo_admin(version = "0.1.2")
        argo_renderer_package(package_name: "@shopify/argo-admin", version: version)
      end

      def argo_renderer_package(package_name:, version: "0.1.2")
        Models::NpmPackage.new(
          name: package_name,
          version: version
        )
      end

      def setup_argo_runtime(renderer_package:, version:, cli_package_name: "@shopify/argo-admin-cli")
        cli = Models::NpmPackage.new(name: cli_package_name, version: version)

        Features::ArgoRuntime.new(renderer: renderer_package, cli: cli)
      end
    end
  end
end
