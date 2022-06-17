# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottlerTest < Minitest::Test
      def setup
        super
        root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("12345678")

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = Theme.new(@ctx, root: root)
          @admin_api = ThemeAdminAPI.new(@ctx, @theme.shop)
      end

      def test_calls_rest_request_when_file_is_too_big
        @throttler = ShopifyCLI::Theme::ThemeAdminAPIThrottler.new(@ctx, @admin_api)
        op = operation("file1.json")

        op.stubs(:size).returns(6_000_000)
        @throttler.expects(:rest_request)

        @throttler.put(path: op[:path], **op.to_h)
      end

      def operation(name)
        {
          path: "themes/#{@theme.id}/assets",
          method: "PUT",
          body: JSON.generate(
            asset: {
              key: name,
            }
          )
        }
      end
    end
  end
end
