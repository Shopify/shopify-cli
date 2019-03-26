require 'test_helper'

module ShopifyCli
  module Tasks
    class TunnelTest < MiniTest::Test
      def test_start_running_returns_url
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(true)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:state).returns(
          url: 'https://example.ngrok.io',
        )
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.start(FakeContext.new)
      end

      def test_start_not_running_returns_starts_ngrok
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(false)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:log).returns(log_fixture)
        FakeContext.any_instance.expects(:spawn).with(
          "exec ngrok http -log=stdout -log-level=debug 8081 > #{log_path}"
        ).returns(1000)
        Process.expects(:detach).with(1000)
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.start(FakeContext.new)
      end

      def test_start_raises_error_on_ngrok_failure
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(false)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:log).returns(log_fixture)
        FakeContext.any_instance.expects(:spawn).with(
          "exec ngrok http -log=stdout -log-level=debug 8081 > #{log_path}"
        ).returns(1000)
        Process.expects(:detach).with(1000)
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.start(FakeContext.new)
      end

      def log_fixture
        @log_fixture ||= File.new(log_path)
      end

      def log_path
        File.join(File.dirname(__FILE__), '../fixtures/ngrok.log')
      end

      class FakeContext
        def spawn(*args)
        end
      end
    end
  end
end
