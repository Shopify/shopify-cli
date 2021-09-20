require "test_helper"

module ShopifyCli
  class TunnelTest < MiniTest::Test
    def setup
      ShopifyCli::Tunnel.any_instance.stubs(:install)
      super
    end

    def test_auth_calls_ngrok_authtoken
      @context.expects(:system).with("#{ShopifyCli.cache_dir}/ngrok", "authtoken", "token")
      ShopifyCli::Tunnel.auth(@context, "token")
    end

    def test_start_running_returns_url
      ShopifyCli::ProcessSupervision.stubs(:running?)
        .with(:ngrok).returns(:true)
      with_log do
        ShopifyCli::Tunnel.start(@context)
        assert_equal "https://example.ngrok.io", ShopifyCli::Tunnel.start(@context)
      end
    end

    def test_start_not_running_starts_ngrok
      with_log do
        ShopifyCli::ProcessSupervision.stubs(:running?).returns(false)
        ShopifyCli::ProcessSupervision.expects(:start).with(
          :ngrok,
          "\"#{File.join(ShopifyCli.cache_dir, "ngrok")}\" http -inspect=false -log=stdout -log-level=debug 8081"
        ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
        @context.expects(:puts).with(@context.message("core.tunnel.start", "https://example.ngrok.io"))
        @context.expects(:puts).with(@context.message("core.tunnel.will_timeout", "7 hours 59 minutes"))
        @context.expects(:puts).with(@context.message("core.tunnel.signup_suggestion", ShopifyCli::TOOL_NAME))
        assert_equal "https://example.ngrok.io", ShopifyCli::Tunnel.start(@context)
      end
    end

    def test_start_running_timed_out_restarts_ngrok
      start_time = Time.now.to_i - (60 * 60 * 9)
      with_log(time: start_time.to_s) do
        ShopifyCli::ProcessSupervision.expects(:start).twice.with(
          :ngrok,
          "\"#{File.join(ShopifyCli.cache_dir, "ngrok")}\" http -inspect=false -log=stdout -log-level=debug 8081"
        ).returns(
          ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000, time: start_time.to_s)
        ).then.returns(
          ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000)
        )
        @context.expects(:puts).with(@context.message("core.tunnel.timed_out"))
        ShopifyCli::ProcessSupervision.expects(:stop)
          .with(:ngrok).returns(true)
        @context.expects(:puts).with(@context.message("core.tunnel.start", "https://example.ngrok.io"))
        @context.expects(:puts).with(@context.message("core.tunnel.will_timeout", "7 hours 59 minutes"))
        @context.expects(:puts).with(@context.message("core.tunnel.signup_suggestion", ShopifyCli::TOOL_NAME))
        assert_equal "https://example.ngrok.io", ShopifyCli::Tunnel.start(@context)
      end
    end

    def test_start_accepts_configurable_port
      configured_port = 3000
      with_log do
        ShopifyCli::ProcessSupervision.stubs(:running?).returns(false)
        ShopifyCli::ProcessSupervision.expects(:start).with(
          :ngrok,
          "\"#{File.join(ShopifyCli.cache_dir, "ngrok")}\" http -inspect=false"\
            " -log=stdout -log-level=debug #{configured_port}"
        ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
        @context.expects(:puts).with(@context.message("core.tunnel.start", "https://example.ngrok.io"))
        @context.expects(:puts).with(@context.message("core.tunnel.will_timeout", "7 hours 59 minutes"))
        @context.expects(:puts).with(@context.message("core.tunnel.signup_suggestion", ShopifyCli::TOOL_NAME))
        assert_equal "https://example.ngrok.io", ShopifyCli::Tunnel.start(@context, port: configured_port)
      end
    end

    def test_start_displays_url_with_account
      with_log(fixture: "ngrok_account") do
        ShopifyCli::ProcessSupervision.stubs(:running?).returns(false)
        ShopifyCli::ProcessSupervision.expects(:start).with(
          :ngrok,
          "\"#{File.join(ShopifyCli.cache_dir, "ngrok")}\" http -inspect=false -log=stdout -log-level=debug 8081"
        ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
        @context.expects(:puts).with(
          @context.message("core.tunnel.start_with_account", "https://example.ngrok.io", "Tom Cruise")
        )
        assert_equal "https://example.ngrok.io", ShopifyCli::Tunnel.start(@context)
      end
    end

    def test_start_raises_error_on_ngrok_failure
      with_log(fixture: "ngrok_error") do
        ShopifyCli::ProcessSupervision.expects(:start).with(
          :ngrok,
          "\"#{File.join(ShopifyCli.cache_dir, "ngrok")}\" http -inspect=false -log=stdout -log-level=debug 8081"
        ).returns(ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000))
        assert_raises ShopifyCli::Tunnel::NgrokError do
          ShopifyCli::Tunnel.start(@context)
        end
      end
    end

    def test_stop_doesnt_stop_what_isnt_started
      ShopifyCli::ProcessSupervision.expects(:running?).with(:ngrok).returns(false)
      @context.expects(:puts).with(@context.message("core.tunnel.not_running"))
      ShopifyCli::Tunnel.stop(@context)
    end

    def test_start_raises_error_when_ngrok_cannot_be_stopped
      ShopifyCli::ProcessSupervision.stubs(:running?).with(:ngrok).returns(true)
      ShopifyCli::ProcessSupervision.stubs(:stop).with(:ngrok).returns(false)
      assert_raises(ShopifyCli::Abort) do
        ShopifyCli::Tunnel.stop(@context)
      end
    end

    def test_stats_returns_the_json_stats_of_all_running_tunnels
      mock_ngrok_tunnels_http_call(response_body: JSON.dump(fake_ngrok_api_response))

      assert_equal fake_ngrok_api_response, Tunnel.stats
    end

    def test_stats_returns_empty_has_if_invalid_response_is_returned
      mock_ngrok_tunnels_http_call(response_body: "{{}")

      assert_nothing_raised do
        assert_equal({}, Tunnel.stats)
      end
    end

    def test_urls_returns_the_list_of_current_running_ngrok_urls
      Tunnel.any_instance.expects(:stats).returns(fake_ngrok_api_response).once
      expected_urls = %w(https://shopify.ngrok.io http://shopify.ngrok.io)

      assert_equal expected_urls, Tunnel.urls
    end

    def test_urls_returns_an_empty_array_if_an_empty_hash_is_returns_from_stats
      Tunnel.any_instance.expects(:stats).returns({}).once

      assert_nothing_raised do
        assert_equal [], Tunnel.urls
      end
    end

    def test_tunnel_running_on_returns_false_if_port_provided_is_available
      mock_ngrok_tunnels_http_call(response_body: JSON.dump(fake_ngrok_api_response))
      port_to_check = 12345
      refute Tunnel.running_on?(port_to_check)
    end

    def test_tunnel_running_on_returns_true_if_tunnel_running_on_provided_port
      mock_ngrok_tunnels_http_call(response_body: JSON.dump(fake_ngrok_api_response))
      port_to_check = 39351
      assert Tunnel.running_on?(port_to_check)
    end

    def test_tunnel_running_on_returns_false_if_tunnel_urls_empty
      mock_ngrok_tunnels_http_call(response_body: JSON.dump({}))
      port_to_check = 39351
      refute Tunnel.running_on?(port_to_check)
    end

    private

    def with_log(fixture: "ngrok", time: Time.now.strftime("%s"))
      log_path = File.join(ShopifyCli::ROOT, "test/fixtures/#{fixture}.log")
      process = ShopifyCli::ProcessSupervision.new(:ngrok, pid: 40000, time: time)
      process.write
      File.write(process.log_path, File.read(log_path))
      yield
      process.stop
    end

    def mock_ngrok_tunnels_http_call(response_body:)
      Net::HTTP
        .expects(:get_response)
        .with(Tunnel::NGROK_TUNNELS_URI)
        .returns(mock(body: response_body))
        .once
    end

    def fake_ngrok_api_response
      @ngrok_api_response ||= JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test", "fixtures", "ngrok_api.json")))
    end
  end
end
