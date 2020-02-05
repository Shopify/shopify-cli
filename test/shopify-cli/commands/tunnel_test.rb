require 'test_helper'

module ShopifyCli
  module Commands
    class TunnelTest < MiniTest::Test
      def setup
        super
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        @cmd = ShopifyCli::Commands::Tunnel
        @cmd.ctx = @context
        @cmd_name = 'tunnel'
      end

      def test_auth
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:auth)
        @cmd.call(['auth'], @cmd_name)
      end

      def test_start
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:call)
        @cmd.call(['start'], @cmd_name)
      end

      def test_stop
        ShopifyCli::Tasks::Tunnel.any_instance.expects(:stop)
        @cmd.call(['stop'], @cmd_name)
      end
    end
  end
end
