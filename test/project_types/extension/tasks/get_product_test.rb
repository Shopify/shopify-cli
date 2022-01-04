# typed: ignore
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class GetProductTest < MiniTest::Test
      include ExtensionTestHelpers::TempProjectSetup

      def test_get_performs_api_request_and_parses_response
        response = mock
        ShopifyCLI::AdminAPI.stubs(:query).returns(response)
        result = mock
        Converters::ProductConverter.expects(:from_hash).with(response).returns(result)
        assert_equal result, Tasks::GetProduct.call(@context, "shop.myshopify.com")
      end

      def test_performs_api_request_and_aborts_if_api_response_is_nil
        ShopifyCLI::AdminAPI.stubs(:query).returns(nil)

        error = assert_raises CLI::Kit::Abort do
          Tasks::GetProduct.call(@context, "shop.myshopify.com")
        end
        assert_includes error.message, "There was an error getting store data"
      end
    end
  end
end
