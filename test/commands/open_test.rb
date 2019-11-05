require 'test_helper'

module ShopifyCli
  module Commands
    class OpenTest < MiniTest::Test
      def test_run
        Tasks::Tunnel.stubs(:call).returns('https://example.com')
        Open.any_instance.expects(:open_url!).with(@context, 'https://example.com')
        run_cmd('open')
      end
    end
  end
end
