require 'test_helper'

module ShopifyCli
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        @command = ShopifyCli::Commands::Tunnel.new
      end

      def test_start
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:call)
        @command.call(['start'], nil)
      end

      def test_stop
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:stop)
        @command.call(['stop'], nil)
      end
    end
  end
end
