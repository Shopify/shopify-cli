require "test_helper"
require "shopify_cli/theme/theme_access_api"

module ShopifyCLI
  module Theme
    class ThemeAccessAPITest < MiniTest::Test
      include TestHelpers::Project

      def test_rest_request_calls_theme_access_api
        api_stub = stub
        shop = "testshop.myshopify.io"
        password = "shptka_XXX"
        url = "https://theme-kit-access.shopifyapps.com/cli/admin/api/unstable/data.json"
        Environment.expects(:admin_auth_token).returns(password)

        ThemeAccessAPI.expects(:new).with(
          ctx: @context,
          token: "shptka_XXX",
          url: url,
        ).returns(api_stub)

        api_stub.expects(:request).with(
          url: url,
          body: nil,
          headers: { "X-Shopify-Shop" => shop },
          method: "GET"
        ).returns("response")

        assert_equal(
          "response",
          ThemeAccessAPI.rest_request(@context,
            shop: shop,
            path: "data.json",
            api_version: "unstable"),
        )
      end

      def test_get_shop_or_abort_reads_from_env
        shop = "testshop.myshopify.io"
        Environment.expects(:store).returns(shop)

        assert_equal(
          shop,
          ThemeAccessAPI.get_shop_or_abort(@context)
        )
      end

      def test_get_shop_or_abort_reads_aborts_when_no_env
        error = assert_raises ShopifyCLI::Abort do
          ThemeAccessAPI.get_shop_or_abort(@context)
        end

        assert_includes error.message, "No store found"
      end
    end
  end
end
