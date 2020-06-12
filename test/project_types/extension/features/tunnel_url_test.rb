# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Features
    class TunnelUrlTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_fetch_returns_the_first_ngrok_url_if_it_exists
        fake_tunnel_uri = 'http://7b121913fab9.ngrok.io'
        fake_tunnel_response = {
          "tunnels": [
            {
              "name": "command_line (http)",
              "uri": "/api/tunnels/command_line%20%28http%29",
              "public_url": fake_tunnel_uri,
              "proto": "http",
              "config": {"addr": "http://localhost:39351", "inspect": true},
              "metrics": {
                "conns": {"count": 0, "gauge": 0, "rate1": 0, "rate5": 0, "rate15": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0},
                "http": {"count": 0, "rate1": 0, "rate5": 0, "rate15": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0}
              }
            },
            {
              "name": "command_line",
              "uri": "/api/tunnels/command_line",
              "public_url": fake_tunnel_uri,
              "proto": "https",
              "config": {"addr": "http://localhost:39351", "inspect": true},
              "metrics": {
                "conns": {"count": 0, "gauge": 0, "rate1": 0, "rate5": 0, "rate15": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0},
                "http": {"count": 0, "rate1": 0, "rate5": 0, "rate15": 0, "p50": 0, "p90": 0, "p95": 0, "p99": 0}
              }
            }
          ],
          "uri": "/api/tunnels"
        }

        mock_ngrok_tunnels_http_call(response_body: JSON.dump(fake_tunnel_response))

        fetched_tunnel_uri = TunnelUrl.fetch
        assert_equal fake_tunnel_uri, fetched_tunnel_uri
      end

      def test_fetch_returns_nil_and_does_not_raise_if_the_response_cannot_be_parsed_as_json
        invalid_json_response = '<html><head></head><body><p>Error</p></html>'

        mock_ngrok_tunnels_http_call(response_body: invalid_json_response)

        assert_nothing_raised do
          assert_nil TunnelUrl.fetch
        end
      end

      def test_fetch_returns_nil_and_does_not_raise_if_the_response_has_no_tunnels
        fake_tunnel_response = {
          "tunnels": [ ],
          "uri": "/api/tunnels"
        }

        mock_ngrok_tunnels_http_call(response_body: JSON.dump(fake_tunnel_response))

        assert_nothing_raised do
          assert_nil TunnelUrl.fetch
        end
      end

      private

      def mock_ngrok_tunnels_http_call(response_body:)
        Net::HTTP
          .expects(:get_response)
          .with(TunnelUrl::NGROK_TUNNELS_URI)
          .returns(mock(body: response_body))
          .once
      end
    end
  end
end
