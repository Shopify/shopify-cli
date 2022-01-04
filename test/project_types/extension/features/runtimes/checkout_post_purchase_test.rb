# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    module Runtimes
      class CheckoutPostPurchaseTest < MiniTest::Test
        include ExtensionTestHelpers::TempProjectSetup

        def test_available_flags_are_supported_for_post_purchase
          flags = [
            :port,
            :public_url,
          ]

          flags.each do |flag|
            assert_equal runtime.supports?(flag), supported
          end
        end

        def test_unsupported_flag_is_not_supported_for_post_purchase
          assert_equal runtime.supports?(:fake_flag), not_supported
        end

        def test_active_runtime_returns_true_for_valid_identifier_and_package_name
          active_runtime = runtime.active_runtime?(cli_package, "CHECKOUT_POST_PURCHASE")
          assert_equal active_runtime, active
        end

        def test_active_runtime_returns_false_for_invalid_identifier_and_package_name
          invalid_package = Models::NpmPackage.new(name: "invalid-package", version: "0.11.0")
          active_runtime = runtime.active_runtime?(invalid_package, "INVALID_IDENTIFIER")
          assert_equal active_runtime, inactive
        end

        def test_active_runtime_returns_false_for_invalid_identifier
          active_runtime = runtime.active_runtime?(cli_package, "INVALID_IDENTIFIER")
          assert_equal active_runtime, inactive
        end

        def test_active_runtime_returns_false_for_invalid_package
          invalid_package = Models::NpmPackage.new(name: "invalid-package", version: "0.11.0")
          active_runtime = runtime.active_runtime?(invalid_package, "CHECKOUT_POST_PURCHASE")
          assert_equal active_runtime, inactive
        end

        private

        def supported
          true
        end

        def active
          true
        end

        def not_supported
          false
        end

        def inactive
          false
        end

        def runtime
          @runtime ||= Runtimes::CheckoutPostPurchase.new
        end

        def cli_package
          Models::NpmPackage.new(name: "@shopify/checkout-ui-extensions-run", version: "0.4.0")
        end
      end
    end
  end
end
