require "test_helper"

module ShopifyCLI
  class TunnelTest < MiniTest::Test
    def test_start_returns_url
      with_log do
        ShopifyCLI::ProcessSupervision.expects(:start).with(:tunnel, tunnel_start_command).returns(process)
        assert_equal "https://example.loca.lt", ShopifyCLI::Tunnel.start(@context)
      end
    end

    def test_start_accepts_configurable_port
      configured_port = 3000
      with_log do
        ShopifyCLI::ProcessSupervision.expects(:start).with(:tunnel, tunnel_start_command(port: configured_port))
          .returns(process)
        ShopifyCLI::Tunnel.start(@context, port: configured_port)
      end
    end

    def test_start_displays_url
      with_log do
        ShopifyCLI::ProcessSupervision.expects(:start).with(:tunnel, tunnel_start_command).returns(process)
        @context.expects(:puts).with(
          @context.message("core.tunnel.start", "https://example.loca.lt")
        )
        ShopifyCLI::Tunnel.start(@context)
      end
    end

    def test_start_raises_error_when_there_is_no_response
      File.write(process.log_path, "")
      ShopifyCLI::ProcessSupervision.expects(:start).with(:tunnel, tunnel_start_command).returns(process)
      ::ShopifyCLI::LogParser.any_instance.expects(:sleep).with(0.5).times(20).returns(nil)
      assert_raises(ShopifyCLI::LogParser::FetchUrlError) do
        ShopifyCLI::Tunnel.start(@context)
      end
    end

    def test_stop_doesnt_stop_what_isnt_started
      ShopifyCLI::ProcessSupervision.expects(:running?).with(:tunnel).returns(false)
      @context.expects(:puts).with(@context.message("core.tunnel.not_running"))
      ShopifyCLI::Tunnel.stop(@context)
    end

    def test_stop_raises_error_when_tunnel_cannot_be_stopped
      ShopifyCLI::ProcessSupervision.stubs(:running?).with(:tunnel).returns(true)
      ShopifyCLI::ProcessSupervision.stubs(:stop).with(:tunnel).returns(false)
      assert_raises(ShopifyCLI::Abort) do
        ShopifyCLI::Tunnel.stop(@context)
      end
    end

    def test_url_returns_the_url
      with_log do
        ShopifyCLI::ProcessSupervision.expects(:running?).returns(true)
        assert_equal "https://example.loca.lt", ShopifyCLI::Tunnel.url(@context)
      end
    end

    def test_url_returns_nil_without_tunnel
      ShopifyCLI::ProcessSupervision.expects(:running?).returns(false)
      assert_nil ShopifyCLI::Tunnel.url(@context)
    end

    private

    def with_log
      log_path = File.join(ShopifyCLI::ROOT, "test/fixtures/tunnel.log")
      process.write
      File.write(process.log_path, File.read(log_path))
      yield
      process.stop
    end

    def tunnel_start_command(port: 8081)
      "npx --yes localtunnel --port #{port}"
    end

    def process
      @process ||= ShopifyCLI::ProcessSupervision.new(:tunnel, pid: 40000)
    end
  end
end
