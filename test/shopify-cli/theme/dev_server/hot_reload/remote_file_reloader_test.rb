# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/hot_reload/remote_file_reloader"
require "shopify_cli/theme/theme"
require_relative "remote_file_test_helper"

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class RemoteFileReloaderTest < RemoteFileTestHelper
          def setup
            super
            shopify_db_mock

            @reloader = RemoteFileReloader.new(ctx, theme: theme, streams: streams)
            @reloader.stubs(:wait)
          end

          def test_reload
            stub_request(:get, "https://shop.myshopify.com/admin/api/unstable/themes/1234/assets.json?asset%5Bkey%5D=assets/liquid.css.liquid")
              .to_return(
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "1234" } }', headers: {} }
              )

            file.stubs(checksum: "1234")

            streams.expects(:broadcast).with('{"modified":["<# assets/liquid.css.liquid>"]}')

            @reloader.expects(:wait).times(6)
            @reloader.reload(file)
          end

          def test_reload_when_the_asset_is_new
            stub_request(:get, "https://shop.myshopify.com/admin/api/unstable/themes/1234/assets.json?asset%5Bkey%5D=assets/liquid.css.liquid")
              .to_return(
                { status: 404, body: "<Not found>", headers: {} },
                { status: 200, body: '{ "asset": { "checksum": "5678" } }', headers: {} },
              )

            file.stubs(checksum: "1234")

            streams.expects(:broadcast).with('{"modified":["<# assets/liquid.css.liquid>"]}')

            @reloader.reload(file)
          end
        end
      end
    end
  end
end
