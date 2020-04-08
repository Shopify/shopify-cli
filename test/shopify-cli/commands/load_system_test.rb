require 'test_helper'

module ShopifyCli
  module Commands
    class LoadSystemTest < MiniTest::Test
      def test_loads_system
        ShopifyCli::Core::Finalize.expects(:reload_shopify_from).with(ShopifyCli::INSTALL_DIR)
        capture_io do
          run_cmd('load-system')
        end
      end
    end
  end
end
