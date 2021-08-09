# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class ProductSubscriptionTest < MiniTest::Test
        include ExtensionTestHelpers

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
          specifications = DummySpecifications.build(identifier: "subscription_management", surface: "admin")

          @identifier = "product_subscription"
          @product_subscription = specifications[@identifier]
        end

        def test_create_uses_standard_argo_create_implementation
          directory_name = "product_subscription"

          Features::Argo.any_instance
            .expects(:create)
            .with(directory_name, @identifier.upcase, @context)
            .once

          @product_subscription.create(directory_name, @context)
        end

        def test_config_uses_standard_argo_config_implementation
          Features::Argo.any_instance.expects(:config).with(@context).once

          @product_subscription.config(@context)
        end

        def test_custom_identifier
          assert_equal "product_subscription", @product_subscription.identifier
        end

        def test_custom_graphql_identifier
          assert_equal "subscription_management", @product_subscription.graphql_identifier
        end
      end
    end
  end
end
