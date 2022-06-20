# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/theme_admin_api_throttler"
require "shopify_cli/theme/theme_admin_api_throttler/put_request"

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

      def test_active_toggling_works
        @throttler = ShopifyCLI::Theme::ThemeAdminAPIThrottler.new(@ctx, @admin_api)
        op1 = generate_operation("file1.json", 10_000)
        op2 = generate_operation("file2.json", 10_000)

        @throttler
          .expects(:bulk_request)
          .once
        @throttler
          .expects(:rest_request)
          .once

        @throttler.put(path: op1.path, **op1.body) { operation_handler_block }
        @throttler.deactivate!
        @throttler.put(path: op2.path, **op2.body) { operation_handler_block }
        @throttler.shutdown
      end

      def test_throttler_throws_error_on_unsuccessful_rest_request
        @throttler = ShopifyCLI::Theme::ThemeAdminAPIThrottler.new(@ctx, @admin_api, false)
        error_body = JSON.generate(
          errors: {
            message: "Testing error",
          }
        )
        ShopifyCLI::AdminAPI
          .stubs(:rest_request)
          .raises(api_error(error_body))
        @ctx.expects(:error).with(error_body)
        op1 = generate_operation("file1.json", 10_000)

        test_operation(@throttler, op1)
        @throttler.shutdown
      end

      def test_throttler_prints_synced_on_successful_rest_request
        @throttler = ShopifyCLI::Theme::ThemeAdminAPIThrottler.new(@ctx, @admin_api, false)
        op1 = generate_operation("file1.json", 10_000)
        resp_body = JSON.generate(
          asset: {
            key: "file1.json",
            checksum: "randomchecksum",
          },
        )
        ShopifyCLI::AdminAPI
          .stubs(:rest_request)
          .with(
            @ctx,
            shop: @theme.shop,
            path: op1.path,
            method: "PUT",
            api_version: "unstable",
            body: JSON.generate({
              asset: {
                key: "file1.json",
                value: "file1.json",
              },
            })
          ).returns([
            200,
            {
              "asset" => {
                "key" => "file1.json",
                "checksum" => "randomchecksum",
              },
            },
            {},
          ])
        @ctx.expects(:puts).with(JSON.parse(resp_body))

        test_operation(@throttler, op1)
        @throttler.shutdown
      end

      private

      def request_body(name)
        JSON.generate(
          asset: {
            key: name,
            value: name,
          }
        )
      end

      def generate_operation(name, size)
        path = "themes/#{@theme.id}/assets.json"
        request = stub(
          "Operation",
          name: name, # debugging
          method: "PUT",
          body: { body: request_body(name) },
          size: size,
          path: path,
          bulk_path: path.gsub(/.json$/, "/bulk.json"),
        )
        request
      end

      def api_error(msg)
        ShopifyCLI::API::APIRequestError.new(msg, response: { body: msg })
      end

      def test_operation(throttler, operation)
        throttler.put(path: operation.path, **operation.body) do |status, body, response|
          if status == 500
            @ctx.error(response.message)
          else
            @ctx.puts(body)
          end
        end
      end
    end
  end
end
