# typed: ignore
require "test_helper"

module ShopifyCLI
  module Commands
    class StoreTest < MiniTest::Test
      def test_can_display_store
        shop = "testshop.myshopify.com"
        ShopifyCLI::AdminAPI.expects(:get_shop_or_abort).with(@context).returns(shop)

        @context.expects(:puts).with(@context.message("core.store.shop", shop))

        run_cmd("store")
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Store.help)
        run_cmd("help store")
      end
    end
  end
end
