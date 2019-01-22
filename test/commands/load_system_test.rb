require 'test_helper'

module ShopifyCli
  module Commands
    class LoadSystemTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::LoadSystem.new
      end

      def test_loads_system
        ShopifyCli::Finalize.expects(:reload_shopify_from).with(ShopifyCli::INSTALL_DIR)
        io = capture_io do
          @command.call([], nil)
        end
      end
    end
  end
end
