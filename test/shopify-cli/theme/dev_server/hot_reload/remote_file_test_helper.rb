# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    class DevServer
      class RemoteFileTestHelper < Minitest::Test
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
