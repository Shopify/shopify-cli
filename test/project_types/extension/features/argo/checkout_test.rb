# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Features
    module Argo
      class CheckoutTest < MiniTest::Test
        include TestHelpers::FakeUI
        include ExtensionTestHelpers::Stubs::ArgoScript

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          @checkout = Features::Argo::Checkout.new
        end

        def test_checkout_method_returns_an_argo_extension_with_the_checkout_post_purchase_template
          assert_equal('https://github.com/Shopify/argo-checkout-template.git', @checkout.git_template)
        end

        def test_checkout_setup_method_returns_an_argo_extension_with_the_checkout_renderer_package_name_name
          assert_equal('@shopify/argo-checkout', @checkout.renderer_package_name)
        end
      end
    end
  end
end
