require 'test_helper'

module ShopifyCli
  module Tasks
    class TunnelTest < MiniTest::Test
      def setup
        Tunnel.any_instance.stubs(:install)
        super
      end

      def test_auth_calls_ngrok_authtoken
        @context.expects(:system).with("#{ShopifyCli::ROOT}/ngrok", 'authtoken', 'token')
        Tunnel.new.auth(@context, 'token')
      end

      def test_start_running_returns_url
        ShopifyCli::ProcessSupervision.stubs(:running?)
          .with(:ngrok).returns(:true)
        with_log do
          Tunnel.new.call(@context)
          assert_equal 'https://example.ngrok.io', @context.app_metadata[:host]
        end
      end

      def test_start_not_running_starts_ngrok
        with_log do
          ShopifyCli::ProcessSupervision.stubs(:running?).returns(false)
          ShopifyCli::ProcessSupervision.expects(:start).with(
            :ngrok,
            "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug 8081"
          ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
          @context.expects(:puts).with(
            "{{v}} ngrok tunnel running at {{underline:https://example.ngrok.io}}"
          )
          assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.new.call(@context)
          assert_equal 'https://example.ngrok.io', @context.app_metadata[:host]
        end
      end

      def test_start_displays_url_with_account
        with_log('ngrok_account') do
          ShopifyCli::ProcessSupervision.stubs(:running?).returns(false)
          ShopifyCli::ProcessSupervision.expects(:start).with(
            :ngrok,
            "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug 8081"
          ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
          @context.expects(:puts).with(
            "{{v}} ngrok tunnel running at {{underline:https://example.ngrok.io}}, with account Tom Cruise"
          )
          assert_equal 'https://example.ngrok.io', ShopifyCli::Tasks::Tunnel.new.call(@context)
        end
      end

      def test_start_raises_error_on_ngrok_failure
        Tunnel.any_instance.stubs(:running?).returns(false)
        with_log('ngrok_error') do
          ShopifyCli::ProcessSupervision.expects(:start).with(
            :ngrok,
            "exec #{File.join(ShopifyCli::ROOT, 'ngrok')} http -log=stdout -log-level=debug 8081"
          ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
          assert_raises ShopifyCli::Tasks::Tunnel::NgrokError do
            Tunnel.new.call(@context)
          end
        end
      end

      def test_stop_doesnt_stop_what_isnt_started
        ShopifyCli::ProcessSupervision.expects(:running?).with(:ngrok).returns(false)
        @context.expects(:puts).with("{{green:x}} ngrok tunnel not running")
        Tunnel.new.stop(@context)
      end

      def test_start_raises_error_when_ngrok_cannot_be_stopped
        ShopifyCli::ProcessSupervision.stubs(:running?).with(:ngrok).returns(true)
        ShopifyCli::ProcessSupervision.stubs(:stop).with(:ngrok).returns(false)
        assert_raises(ShopifyCli::Abort) do
          Tunnel.new.stop(@context)
        end
      end

      def with_log(fixture = 'ngrok')
        log_path = File.join(ShopifyCli::ROOT, "test/fixtures/#{fixture}.log")
        process = ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000)
        process.write
        File.write(process.log_path, File.read(log_path))
        yield
        process.unlink
      end
    end
  end
end
