require 'test_helper'

module ShopifyCli
  module Tasks
    class TunnelTest < MiniTest::Test
      def test_start_running_returns_url
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(true)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:state).returns(
          url: 'https://example.ngrok.io',
        )
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.start
      end

      def test_start_not_running_returns_starts_ngrok
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(false)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:log).returns(File.new('/tmp/foo'))
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:fetch_url).returns(
          'https://example.ngrok.io'
        )
        Kernel.expects(:spawn).with(
          'exec ngrok http -log=stdout -log-level=debug 8081 > /tmp/foo'
        ).returns(1000)
        Process.expects(:detach).with(1000)
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.start
      end
    end
  end
end
