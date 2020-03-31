require 'test_helper'

module Rails
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:rails)
      end

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
