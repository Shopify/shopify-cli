# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    module Converters
      class ProductConverterTest < MiniTest::Test
        include ExtensionTestHelpers::TempProjectSetup

        def test_product_converter_from_hash_parses_product_correctly
          variant_id = 987654321
          response = JSON.parse(mock_api_response(variant_id))
          product = Converters::ProductConverter.from_hash(response)
          assert_equal(variant_id, product.variant_id)
          assert_kind_of(Models::Product, product)
        end

        def test_product_converter_returns_nil_for_empty_hash
          assert_nil Converters::ProductConverter.from_hash(nil)
        end

        def test_product_converter_returns_nil_if_no_variant_exists
          assert_nil Converters::ProductConverter.from_hash({})
        end

        private

        def mock_api_response(variant_id)
          {
            "data": {
              "products": {
                "edges": [
                  {
                    "node": {
                      "id": "gid://shopify/Product/123456789",
                      "variants": {
                        "edges": [
                          {
                            "node": {
                              "id": "gid://shopify/ProductVariant/#{variant_id}",
                            },
                          },
                        ],
                      },
                    },
                  },
                ],
              },
            },
          }.to_json
        end
      end
    end
  end
end
