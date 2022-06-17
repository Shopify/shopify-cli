# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler/errors"
require "shopify_cli/theme/theme_admin_api_throttler/response_parser"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class ResponseParserTest < Minitest::Test
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
          parser = ResponseParser.new({
            "results" => [
              {
                "code" => 200,
                "body" => {
                  "asset" => {
                    "key" => "templates/index.liquid",
                    "public_url" => nil,
                    "created_at" => "2022-04-05T13:20:49-04:00",
                    "updated_at" => "2022-04-05T13:20:49-04:00",
                    "content_type" => "application/x-liquid",
                    "size" => 3049,
                    "checksum" => "1879a06996941b2ff1ff485a1fe60a97",
                    "theme_id" => 828155753,
                  },
                },
              },
              {
                "code" => 200,
                "body" => {
                  "asset" => {
                    "key" => "icon-minus.liquid",
                    "public_url" => nil,
                    "created_at" => "2022-04-05T13:20:49-04:00",
                    "updated_at" => "2022-04-05T13:20:49-04:00",
                    "content_type" => "application/x-liquid",
                    "size" => 3049,
                    "checksum" => "1879a06996941b2323456f485a1fe60a97",
                    "theme_id" => 828155753,
                  },
                },
              },
            ],
          })
          parsed_response = parser.parse
          expected_response = [
            [
              200,
              {
                "asset" => {
                  "key" => "templates/index.liquid",
                  "public_url" => nil,
                  "created_at" => "2022-04-05T13:20:49-04:00",
                  "updated_at" => "2022-04-05T13:20:49-04:00",
                  "content_type" => "application/x-liquid",
                  "size" => 3049,
                  "checksum" => "1879a06996941b2ff1ff485a1fe60a97",
                  "theme_id" => 828155753,
                },
              },
            ],
            [
              200,
              {
                "asset" => {
                  "key" => "icon-minus.liquid",
                  "public_url" => nil,
                  "created_at" => "2022-04-05T13:20:49-04:00",
                  "updated_at" => "2022-04-05T13:20:49-04:00",
                  "content_type" => "application/x-liquid",
                  "size" => 3049,
                  "checksum" => "1879a06996941b2323456f485a1fe60a97",
                  "theme_id" => 828155753,
                },
              },
            ],
          ]

          assert_equal(parsed_response, expected_response)
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
