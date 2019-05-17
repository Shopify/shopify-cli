require 'test_helper'

module ShopifyCli
  module Tasks
    class TunnelTest < MiniTest::Test
      include TestHelpers::Context

      def setup
        Tunnel.any_instance.stubs(:pid_file).returns(pid_path)
        Tunnel.any_instance.stubs(:install)
        super
      end

      def test_start_running_returns_url
        with_log do
          ShopifyCli::Helpers::ProcessSupervision.stubs(:running?)
            .with(40000).returns(:true)
          FakeFS::FileSystem.clone(pid_path)
          Tunnel.new.call(@context)
          assert_equal 'https://example.ngrok.io', @context.app_metadata[:host]
        end
      end

      def test_start_not_running_starts_ngrok
        ShopifyCli::Helpers::ProcessSupervision.stubs(:running?).returns(false)
        with_log do
          ShopifyCli::Helpers::ProcessSupervision.expects(:start).with(
            "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug 8081 > /tmp/ngrok.log"
          ).returns(40004)
          @context.expects(:puts).with(
            "{{green:✔︎}} ngrok tunnel running at https://example.ngrok.io"
          )
          assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.new.call(@context)
          assert File.read(pid_path).include?('"pid":40004')
          assert_equal 'https://example.ngrok.io', @context.app_metadata[:host]
        end
      end

      def test_start_raises_error_on_ngrok_failure
        Tunnel.any_instance.stubs(:running?).returns(false)
        with_log('ngrok_error') do
          ShopifyCli::Helpers::ProcessSupervision.expects(:start).with(
            "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug 8081 > /tmp/ngrok.log"
          )
          assert_raises ShopifyCli::Tasks::Tunnel::NgrokError do
            Tunnel.new.call(@context)
          end
        end
      end

      def with_log(fixture = 'ngrok')
        log_path = File.join(ShopifyCli::ROOT, "test/fixtures/#{fixture}.log")
        FakeFS::FileSystem.clone(log_path)
        Tunnel.any_instance.stubs(:log).returns(
          FakeLogger.new(log_path)
        )
        yield(log_path)
      end

      def pid_path
        @pid_path ||= File.join(ShopifyCli::ROOT, 'test/fixtures/ngrok.pid')
      end

      class FakeLogger < ShopifyCli::Tasks::Tunnel::Logger
        def to_s
          '/tmp/ngrok.log'
        end
      end
    end
  end
end
