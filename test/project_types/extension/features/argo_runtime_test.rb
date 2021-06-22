# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRuntimeTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_supports_port
        runtimes = {
          checkout_runtime => supports_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_port|
          assert_equal accepts_port, runtime.supports?(:port)
        end
      end

      def test_supports_public_url
        runtimes = {
          checkout_runtime => supports_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_tunnel|
          assert_equal accepts_tunnel, runtime.supports?(:public_url)
        end
      end

      def test_supports_uuid
        runtimes = {
          checkout_runtime => does_not_support_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_uuid|
          assert_equal accepts_uuid, runtime.supports?(:uuid)
        end
      end

      def test_supports_renderer_version
        runtimes = {
          checkout_runtime => does_not_support_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_renderer_version|
          assert_equal accepts_renderer_version, runtime.supports?(:renderer_version)
        end
      end

      def test_supports_api_key
        runtimes = {
          checkout_runtime => does_not_support_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_api_key|
          assert_equal accepts_api_key, runtime.supports?(:api_key)
        end
      end

      def test_supports_shop
        runtimes = {
          checkout_runtime => does_not_support_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_shop|
          assert_equal accepts_shop, runtime.supports?(:shop)
        end
      end

      def test_supports_name
        runtimes = {
          checkout_runtime => does_not_support_feature,
          admin_runtime => supports_feature,
        }

        runtimes.each do |runtime, accepts_name|
          assert_equal accepts_name, runtime.supports?(:name)
        end
      end

      private

      def checkout_runtime
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-run", version: "0.4.0"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-post-purchase", version: "0.9.0")
        )
      end

      def admin_runtime
        ArgoRuntime.new(
          cli: Models::NpmPackage.new(name: "@shopify/argo-admin-cli", version: "0.11.0"),
          renderer: Models::NpmPackage.new(name: "@shopify/argo-admin", version: "0.9.3")
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
