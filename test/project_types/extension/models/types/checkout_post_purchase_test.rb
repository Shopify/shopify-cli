# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    module Types
      class CheckoutPostPurchaseTest < MiniTest::Test
        def setup
          super
          YAML.stubs(:load_file).returns({})
          ShopifyCli::ProjectType.load_type(:extension)
          Features::Argo.checkout.stubs(:config).returns({})
          Features::ArgoConfig.stubs(:parse_yaml).returns({})

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
          Features::Argo.checkout.expects(:config).with(@context).once.returns({})
          @checkout_post_purchase.config(@context)
        end

        def test_config_merges_with_standard_argo_config_implementation
          script_content = "alert(true)"
          metafields = [{ key: 'a-key', namespace: 'a-namespace' }]

          initial_config = { script_content: script_content }
          yaml_config = { "metafields": metafields }

          Features::Argo.checkout.expects(:config).with(@context).once.returns(initial_config)
          Features::ArgoConfig.stubs(:parse_yaml).returns(yaml_config)

          config = @checkout_post_purchase.config(@context)

          assert_equal(metafields, config[:metafields])
          assert_equal(script_content, config[:script_content])
        end

        def test_config_passes_allowed_keys
          Features::Argo.checkout.stubs(:config).returns({})
          Features::ArgoConfig.expects(:parse_yaml).with(@context, [:metafields]).once.returns({})
          @checkout_post_purchase.config(@context)
        end
      end
    end
  end
end
