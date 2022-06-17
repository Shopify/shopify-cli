# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/errors"
require "shopify_cli/theme/theme_admin_api_throttler/request_parser"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class RequestParserTest < Minitest::Test
        def setup
          super

          ShopifyCLI::DB
            .stubs(:exists?)
            .with(:shop)
            .returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("shop.myshopify.com")
        end

        def test_parse
          parser = RequestParser.new([
            ShopifyCLI::Theme::ThemeAdminAPIThrottler::PutRequest.new(
              "themes/#{theme.id}/assets.json",
              JSON.generate({
                asset: {
                  key: "assets/theme.css",
                  value: theme["assets/theme.css"].read,
                },
              }),
            ),
            ShopifyCLI::Theme::ThemeAdminAPIThrottler::PutRequest.new(
              "themes/#{theme.id}/assets.json",
              JSON.generate({
                asset: {
                  key: "assets/logo.png",
                  attachment: Base64.encode64(theme["assets/logo.png"].read),
                },
              }),
            ),
          ])

          actual_request = parser.parse
          expected_request = {
            path: "themes/123/assets/bulk.json",
            method: "PUT",
            body: JSON.generate({
              assets: [
                {
                  key: "assets/theme.css",
                  value: theme["assets/theme.css"].read,
                },
                {
                  key: "assets/logo.png",
                  attachment: Base64.encode64(theme["assets/logo.png"].read),
                },
              ],
            }),
          }

          assert_equal(expected_request, actual_request)
        end

        private

        def theme
          @theme ||= Theme.new(ctx, root: root, id: "123")
        end

        def ctx
          @ctx ||= TestHelpers::FakeContext.new(root: root)
        end

        def root
          ShopifyCLI::ROOT + "/test/fixtures/theme"
        end
      end
    end
  end
end
