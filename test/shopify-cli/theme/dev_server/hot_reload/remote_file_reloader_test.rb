# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/hot_reload/remote_file_reloader"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class RemoteFileReloaderTest < Minitest::Test
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

          private

          def file
            return @file if @file
            @file = mock("File")
            @file.stubs(relative_path: "assets/liquid.css.liquid")
            @file.stubs(to_s: "<# assets/liquid.css.liquid>")
            @file
          end

          def shopify_db_mock
            ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
            ShopifyCLI::DB.stubs(:get).with(:shop).returns("shop.myshopify.com")
            ShopifyCLI::DB.stubs(:get).with(:shopify_exchange_token).returns("token1234")
            ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(nil)
          end

          def streams
            @streams ||= mock("Streams")
          end

          def theme
            return @theme if @theme
            @theme = ShopifyCLI::Theme::Theme.new(@ctx, root: root)
            @theme.stubs(id: "1234")
            @theme
          end

          def root
            @root ||= ShopifyCLI::ROOT + "/test/fixtures/theme"
          end

          def ctx
            @ctx ||= TestHelpers::FakeContext.new(root: root)
          end
        end
      end
    end
  end
end
