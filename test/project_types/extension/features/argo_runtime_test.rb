# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRuntimeTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_admin_runtime_is_returned_for_admin_extensions
        runtime = ArgoRuntime.find(
          cli_package: Models::NpmPackage.new(name: "@shopify/admin-ui-extensions-run", version: "0.13.0"),
          identifier: "PRODUCT_SUBSCRIPTION"
        )
        assert_equal(Runtimes::Admin, runtime.class)
      end

      def test_checkout_ui_extension_runtime_is_returned_for_checkout_ui_extensions
        runtime = ArgoRuntime.find(
          cli_package: Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.4.0"),
          identifier: "CHECKOUT_UI_EXTENSION"
        )
        assert_equal(Runtimes::CheckoutUiExtension, runtime.class)
      end

      def test_checkout_ui_extension_runtime_is_returned_for_legacy_checkout_argo_extensions
        runtime = ArgoRuntime.find(
          cli_package: Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.4.0"),
          identifier: "CHECKOUT_ARGO_EXTENSION"
        )
        assert_equal(Runtimes::CheckoutUiExtension, runtime.class)
      end

      def test_checkout_post_purchase_runtime_is_returned_for_checkout_post_purchase_extensions
        runtime = ArgoRuntime.find(
          cli_package: Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.4.0"),
          identifier: "CHECKOUT_POST_PURCHASE"
        )
        assert_equal(Runtimes::CheckoutPostPurchase, runtime.class)
      end
    end
  end
end
