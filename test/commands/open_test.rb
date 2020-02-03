require 'test_helper'

module ShopifyCli
  module Commands
    class OpenTest < MiniTest::Test
      def setup
        super
        Helpers::AccessToken.stubs(:read).returns('myaccesstoken')
        @cmd = ShopifyCli::Commands::Open
        @cmd.ctx = @context
      end

      def test_run
        Tasks::Tunnel.stubs(:call).returns('https://example.com')
        Open.any_instance.expects(:open_url!).with(@context, 'https://example.com')
        @cmd.call([], 'open')
      end
    end
  end
end
