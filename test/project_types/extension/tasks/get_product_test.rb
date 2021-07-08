require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class GetProductTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_get_product_returns_a_product
        response = JSON.parse(mock_api_response)
        ShopifyCli::AdminAPI.stubs(:query).returns(response)

        result = Tasks::GetProduct.call(@context, "shop.myshopify.com")
        assert_kind_of(Models::Product, result)
      end

      def test_get_product_returns_nil_for_no_products
        ShopifyCli::AdminAPI.stubs(:query).returns({})

        result = Tasks::GetProduct.call(@context, "shop.myshopify.com")
        assert_nil result
      end

      def test_get_product_raises_error_for_nil_response
        ShopifyCli::AdminAPI.stubs(:query).returns(nil)

        error = assert_raises CLI::Kit::Abort do
          Tasks::GetProduct.call(@context, "shop.myshopify.com")
        end
        assert_includes error.message, "There was an error getting store data"
      end

      private

      def mock_api_response
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
                            "id": "gid://shopify/ProductVariant/987654321",
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
