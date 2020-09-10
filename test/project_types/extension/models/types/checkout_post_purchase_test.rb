# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    module Types
      class CheckoutPostPurchaseTest < MiniTest::Test
        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          @checkout_post_purchase = Models::Type.load_type(CheckoutPostPurchase::IDENTIFIER)
        end

        def test_create_uses_standard_argo_create_implementation
          directory_name = 'checkout_post_purchase'

          Features::Argo.checkout
            .expects(:create)
            .with(directory_name, CheckoutPostPurchase::IDENTIFIER, @context)
            .once

          @checkout_post_purchase.create(directory_name, @context)
        end

        def test_config_uses_standard_argo_config_implementation
          Features::Argo.checkout.expects(:config).with(@context).once

          @checkout_post_purchase.config(@context)
        end
      end
    end
  end
end
