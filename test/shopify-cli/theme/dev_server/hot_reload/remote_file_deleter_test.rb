# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/hot_reload/remote_file_deleter"
require "shopify_cli/theme/theme"
require_relative "remote_file_test_helper"

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class RemoteFileDeleterTest < RemoteFileTestHelper
          def setup
            super
            shopify_db_mock

            @deleter = RemoteFileDeleter.new(ctx, theme: theme, streams: streams)
            @deleter.stubs(:wait)
          end

          def test_delete
            stub_request(:get, "https://shop.myshopify.com/admin/api/unstable/themes/1234/assets.json?asset%5Bkey%5D=assets/liquid.css.liquid")
              .to_return(
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 404, body: "", headers: {} }
              )

            file.stubs(checksum: "5678")

            streams.expects(:broadcast).with('{"deleted":["<# assets/liquid.css.liquid>"]}')

            @deleter.expects(:wait).times(6)
            @deleter.delete(file)
          end
        end
      end
    end
  end
end
