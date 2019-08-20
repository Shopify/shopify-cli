require 'test_helper'

module ShopifyCli
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::Tunnel.new
      end

      def test_auth
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:auth)
        @command.call(['auth'], nil)
      end

      def test_start
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:call)
        @command.call(['start'], nil)
      end

      def test_stop
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:stop)
        @command.call(['stop'], nil)
      end

      def test_stop_rescues
        ShopifyCli::Helpers::ProcessSupervision.stubs(:running?).with(:ngrok).returns(true)
        ShopifyCli::Helpers::ProcessSupervision.stubs(:stop).with(:ngrok).raises

        io = capture_io do
          @command.call(['stop'], nil)
        end
        output = io.join

        assert_match(/could not be stopped/, output)
      end
    end
  end
end
