# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoRuntimeTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_checkout_runtime_is_returned_for_checkout_extensions
        checkout_runtime = ArgoRuntime.build(
          cli_package: Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.4.0"),
          identifier: "CHECKOUT_UI_EXTENSION"
        )

        assert_equal Runtimes::CheckoutRuntime, checkout_runtime.class
      end

      def test_admin_runtime_is_returned_for_admin_extensions
        admin_runtime = ArgoRuntime.build(
          cli_package: Models::NpmPackage.new(name: "@shopify/admin-ui-extensions-run", version: "0.13.0"),
          identifier: "PRODUCT_SUBSCRIPTION"
        )

        assert_equal Runtimes::AdminRuntime, admin_runtime.class
      end

      def test_checkout_post_purchase_runtime_is_returned_for_post_purchase_extensions
        post_purchase_runtime = ArgoRuntime.build(
          cli_package: Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.13.0"),
          identifier: "CHECKOUT_POST_PURCHASE"
        )

        assert_equal Runtimes::CheckoutPostPurchaseRuntime, post_purchase_runtime.class
      end
    end
  end
end
