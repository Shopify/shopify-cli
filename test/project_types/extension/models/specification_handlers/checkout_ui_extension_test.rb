# typed: ignore
# frozen_string_literal: true

require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class CheckoutUiExtensionTest < MiniTest::Test
        include ExtensionTestHelpers

        def setup
          super
          YAML.stubs(:load_file).returns({})
          ShopifyCLI::ProjectType.load_type(:extension)
          Features::Argo.any_instance.stubs(:config).returns({})
          Features::ArgoConfig.stubs(:parse_yaml).returns({})

          specifications = DummySpecifications.build(identifier: "checkout_ui_extension", surface: "checkout")

          @identifier = "CHECKOUT_UI_EXTENSION"
          @checkout_ui_extension = specifications[@identifier]
        end

        def test_create_uses_standard_argo_create_implementation
          directory_name = "checkout_ui_extension"

          Features::Argo.any_instance
            .expects(:create)
            .with(directory_name, @identifier, @context)
            .once

          @checkout_ui_extension.create(directory_name, @context)
        end

        def test_config_uses_standard_argo_config_implementation
          Features::Argo.any_instance.expects(:config).with(@context, include_renderer_version: false).once.returns({})
          @checkout_ui_extension.config(@context)
        end

        def test_config_merges_with_standard_argo_config_implementation
          script_content = "alert(true)"
          metafields = [{ key: "a-key", namespace: "a-namespace" }]
          extension_points = ["Checkout::Feature::Render"]
          name = "Extension name"

          initial_config = { script_content: script_content }
          yaml_config = { "extension_points": extension_points, "metafields": metafields, "name": name }

          Features::Argo.any_instance.expects(:config).with(@context, include_renderer_version: false).once
            .returns(initial_config)
          Features::ArgoConfig.stubs(:parse_yaml).returns(yaml_config)

          config = @checkout_ui_extension.config(@context)
          assert_equal(metafields, config[:metafields])
          assert_equal(extension_points, config[:extension_points])
          assert_equal(name, config[:name])
          assert_equal(script_content, config[:script_content])
        end

        def test_config_passes_allowed_keys
          Features::Argo.any_instance.stubs(:config).returns({})
          Features::ArgoConfig
            .expects(:parse_yaml)
            .with(@context, [:extension_points, :metafields, :name])
            .once
            .returns({})

          @checkout_ui_extension.config(@context)
        end

        def test_graphql_identifier
          assert_equal @identifier, @checkout_ui_extension.graphql_identifier
        end

        def test_build_resource_url
          shop = stub
          product = mock(variant_id: 0)

          Tasks::GetProduct.expects(:call).with(@context, shop).returns(product)

          resource_url = @checkout_ui_extension.build_resource_url(context: @context, shop: shop)
          assert_equal "/cart/0:1", resource_url
        end

        def test_build_resource_url_nil_safety
          shop = stub
          Tasks::GetProduct.expects(:call).with(@context, shop).returns(nil)

          resource_url = @checkout_ui_extension.build_resource_url(context: @context, shop: shop)
          assert_nil resource_url
        end
      end
    end
  end
end
