require 'test_helper'

module ShopifyCli
  module Commands
    class TunnelTest < MiniTest::Test
      def test_auth
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:auth)
        run_cmd('tunnel auth')
      end

      def test_start
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:call)
        run_cmd('tunnel start')
      end

      def test_stop
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:stop)
        run_cmd('tunnel stop')
      end
    end
  end
end
