# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoCliCompatibilityTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      Package = Struct.new(:name, :version)

      def test_accepts_port_is_true_for_supported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
        installed_cli_package: installed_cli_package)

        assert_predicate(argo_cli_compatibility, :accepts_port?)
      end

      def test_accepts_port_is_false_for_unsupported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
        installed_cli_package: installed_cli_package)

        refute_predicate(argo_cli_compatibility, :accepts_port?)
      end

      def test_accepts_tunnel_url_is_true_for_supported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
          installed_cli_package: installed_cli_package)

        assert_predicate(argo_cli_compatibility, :accepts_tunnel_url?)
      end

      def test_accepts_tunnel_url_is_fales_for_unsupported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
          installed_cli_package: installed_cli_package)

        refute_predicate(argo_cli_compatibility, :accepts_tunnel_url?)
      end

      def test_accepts_uuid_is_true_for_supported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
          installed_cli_package: installed_cli_package)

        assert_predicate(argo_cli_compatibility, :accepts_uuid?)
      end

      def test_accepts_uuid_is_false_for_unsupported_versions
        argo_admin = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_admin,
          installed_cli_package: installed_cli_package)

        refute_predicate(argo_cli_compatibility, :accepts_uuid?)
      end

      def test_accepts_argo_version_returns_true_for_admin_renderer
        argo_checkout = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-admin",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.11.0")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_checkout,
          installed_cli_package: installed_cli_package)

        assert_predicate(argo_cli_compatibility, :accepts_argo_version?)
      end

      def test_accepts_argo_version_returns_false_for_non_admin_renderer
        argo_checkout = Features::ArgoRendererPackage.new(package_name: "@shopify/argo-checkout",
          version: "0.0.1-doesnt-matter")

        installed_cli_package = Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.0.1")

        argo_cli_compatibility = Features::ArgoCliCompatibility.new(renderer_package: argo_checkout,
          installed_cli_package: installed_cli_package)

        refute_predicate(argo_cli_compatibility, :accepts_argo_version?)
      end
    end
  end
end
