# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRuntimeTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_accepts_port
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => supports_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => does_not_support_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_port|
          assert_equal accepts_port, runtime.accepts_port?
        end
      end

      def test_accepts_tunnel_url
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => supports_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => does_not_support_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_tunnel|
          assert_equal accepts_tunnel, runtime.accepts_tunnel_url?
        end
      end

      def test_accepts_uuid
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => does_not_support_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => does_not_support_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_uuid|
          assert_equal accepts_uuid, runtime.accepts_uuid?
        end
      end

      def test_accepts_argo_version
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => does_not_support_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => supports_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_argo_version|
          assert_equal accepts_argo_version, runtime.accepts_argo_version?
        end
      end

      def test_accepts_api_key
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => does_not_support_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => does_not_support_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_argo_version|
          assert_equal accepts_argo_version, runtime.accepts_api_key?
        end
      end

      def test_accepts_shop
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => does_not_support_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => does_not_support_feature,
          admin_runtime_0_9_2 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_argo_version|
          assert_equal accepts_argo_version, runtime.accepts_shop?
        end
      end

      def test_accepts_name
        runtimes = {
          checkout_runtime_0_3_8 => does_not_support_feature,
          checkout_runtime_0_4_0 => does_not_support_feature,
          admin_runtime_0_11_0 => supports_feature,
          admin_runtime_0_9_3 => supports_feature,
          admin_runtime_0_9_2 => supports_feature,
          admin_runtime_0_9_0 => supports_feature,
          admin_runtime_0_8_9 => does_not_support_feature,
        }

        runtimes.each do |runtime, accepts_argo_version|
          assert_equal accepts_argo_version, runtime.accepts_name?
        end
      end

      private

      def checkout_runtime_0_3_8
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.3.8"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-post-purchase", version: "0.9.0")
        )
      end

      def checkout_runtime_0_4_0
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.4.0"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-post-purchase", version: "0.9.0")
        )
      end

      def admin_runtime_0_9_3
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.3"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.3")
        )
      end

      def admin_runtime_0_11_0
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.3")
        )
      end

      def admin_runtime_0_9_2
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.2"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.3")
        )
      end

      def admin_runtime_0_9_0
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.9.0"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.0")
        )
      end

      def admin_runtime_0_8_9
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.8.9"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.8.9")
        )
      end

      def supports_feature
        true
      end

      def does_not_support_feature
        false
      end
    end
  end
end
