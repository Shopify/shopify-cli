# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    module Types
      class ProductSubscriptionTest < MiniTest::Test
        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          @product_subscription = Models::Type.load_type(ProductSubscription::IDENTIFIER)
        end

        def test_create_uses_standard_argo_create_implementation
          directory_name = 'product_subscription'

          Features::Argo::Admin.any_instance
            .expects(:create)
            .with(directory_name, 'SUBSCRIPTION_MANAGEMENT', @context)
            .once

          @product_subscription.create(directory_name, @context)
        end

        def test_config_uses_standard_argo_config_implementation
          Features::Argo::Admin.any_instance.expects(:config).with(@context).once

          @product_subscription.config(@context)
        end
      end
    end
  end
end
