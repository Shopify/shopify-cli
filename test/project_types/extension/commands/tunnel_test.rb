# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Commands
    class TunnelTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call)
      end

      def test_prints_help
        @context.expects(:puts).with(Extension::Command::Tunnel.help)
        run_tunnel("help")
      end

      def test_auth_errors_if_no_token_is_provided
        io = capture_io { run_tunnel(Extension::Command::Tunnel::AUTH_SUBCOMMAND) }

        assert_message_output(io: io, expected_content: [
          @context.message("tunnel.missing_token"),
          Extension::Command::Tunnel.help,
          Extension::Command::Tunnel.extended_help,
        ])
      end

      def test_auth_runs_the_core_cli_tunnel_auth_if_token_is_present
        # skip("Need to revisit processing of sub-sub-commands")
        fake_token = "FAKE_TOKEN"
        ShopifyCLI::Tunnel.expects(:auth).with(@context, fake_token).once

        capture_io { run_tunnel(Extension::Command::Tunnel::AUTH_SUBCOMMAND, fake_token) }
      end

      def test_start_runs_with_the_default_port_if_no_port_provided
        ShopifyCLI::Tunnel.expects(:start).with(@context, port: Extension::Command::Tunnel::DEFAULT_PORT).once

        capture_io { run_tunnel(Extension::Command::Tunnel::START_SUBCOMMAND) }
      end

      def test_start_runs_with_the_requested_port_if_provided
        ShopifyCLI::Tunnel.expects(:start).with(@context, port: 9999).once

        capture_io { run_tunnel(Extension::Command::Tunnel::START_SUBCOMMAND, "--port=9999") }
      end

      def test_start_aborts_if_an_invalid_port_is_provided
        # skip("Need to revisit processing of sub-sub-commands")
        invalid_port = "NOT_PORT"

        ShopifyCLI::Tunnel.expects(:start).never

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          run_tunnel(Extension::Command::Tunnel::START_SUBCOMMAND, "--port=#{invalid_port}")
        end

        assert_message_output(io: io, expected_content: [
          @context.message("tunnel.invalid_port", invalid_port),
        ])
      end

      def test_stop_runs_the_core_cli_tunnel_stop
        # skip("Need to revisit processing of sub-sub-commands")
        ShopifyCLI::Tunnel.expects(:stop).with(@context).once

        capture_io { run_tunnel(Extension::Command::Tunnel::STOP_SUBCOMMAND) }
      end

      def test_status_outputs_no_tunnel_running_if_tunnel_urls_returns_empty
        ShopifyCLI::Tunnel.expects(:urls).returns([]).once

        io = capture_io { run_tunnel(Extension::Command::Tunnel::STATUS_SUBCOMMAND) }

        assert_message_output(io: io, expected_content: @context.message("tunnel.no_tunnel_running"))
      end

      def test_status_outputs_the_https_url_of_the_running_tunnel_url_if_returned_by_tunnel_urls
        fake_http_url = "http://12345.ngrok.io"
        fake_https_url = "https://12345.ngrok.io"
        ShopifyCLI::Tunnel.expects(:urls).returns([fake_http_url, fake_https_url]).once

        io = capture_io { run_tunnel(Extension::Command::Tunnel::STATUS_SUBCOMMAND) }

        assert_message_output(io: io, expected_content: @context.message("tunnel.tunnel_running_at", fake_https_url))
      end

      def test_status_outputs_the_http_url_of_the_running_tunnel_url_if_no_https_url_is_returned_by_tunnel_urls
        fake_http_url = "http://12345.ngrok.io"
        ShopifyCLI::Tunnel.expects(:urls).returns([fake_http_url]).once

        io = capture_io { run_tunnel(Extension::Command::Tunnel::STATUS_SUBCOMMAND) }

        assert_message_output(io: io, expected_content: @context.message("tunnel.tunnel_running_at", fake_http_url))
      end

      private

      def run_tunnel(*args)
        run_cmd("extension tunnel " + args.join(" "))
      end
    end
  end
end
