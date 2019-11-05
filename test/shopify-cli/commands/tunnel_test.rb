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

      def test_stop_rescues
        ShopifyCli::Helpers::ProcessSupervision.stubs(:running?).with(:ngrok).returns(true)
        ShopifyCli::Helpers::ProcessSupervision.stubs(:stop).with(:ngrok).raises

        io = capture_io do
          run_cmd('tunnel stop')
        end
        output = io.join

        assert_match(/could not be stopped/, output)
      end
    end
  end
end
