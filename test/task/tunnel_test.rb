require 'test_helper'

module ShopifyCli
  module Tasks
    class TunnelTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:pid_file).returns(pid_path)
        super
        # FakeFS::FileSystem.clone(pid_path)
      end

      def test_start_running_returns_url
        stub_binary
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(true)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:state).returns(
          url: 'https://example.ngrok.io',
        )
        assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.new.call(@context)
      end

      def test_start_not_running_returns_starts_ngrok
        binary = stub_binary
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(false)
        with_log do |log_path|
          @context.expects(:spawn).with(
            "exec #{binary} http -log=stdout -log-level=debug 8081 > #{log_path}",
            chdir: ShopifyCli::ROOT
          ).returns(1000)
          Process.expects(:detach).with(1000)
          @context.expects(:puts).with(
            "{{green:✔︎}} ngrok tunnel running at https://example.ngrok.io"
          )
          assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.new.call(@context)
        end
      end

      def test_start_raises_error_on_ngrok_failure
        binary = stub_binary
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:running?).returns(false)
        with_log('ngrok_error') do |log_path|
          @context.expects(:spawn).with(
            "exec #{binary} http -log=stdout -log-level=debug 8081 > #{log_path}",
            chdir: ShopifyCli::ROOT
          ).returns(1000)
          assert_raises ShopifyCli::Tasks::Tunnel::NgrokError do
            ShopifyCli::Tasks::Tunnel.new.call(@context)
          end
        end
      end

      def with_log(fixture = 'ngrok')
        log_path = File.join(File.absolute_path(File.dirname(__FILE__)), "../fixtures/#{fixture}.log")
        # FakeFS::FileSystem.clone(log_path)
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:log).returns(log_path)
        yield(log_path)
      end

      def stub_binary
        ShopifyCli::Tasks::Tunnel.any_instance.stubs(:install)
        binary = File.join(ShopifyCli::ROOT, 'ngrok')
        # FakeFS::FileSystem.clone(binary)
        binary
      end

      def pid_path
        @pid_path ||= File.join(File.absolute_path(File.dirname(__FILE__)), '../fixtures/ngrok.pid')
      end
    end
  end
end
