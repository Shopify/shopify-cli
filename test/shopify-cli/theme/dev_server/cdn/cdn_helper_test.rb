# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/cdn/cdn_helper"

module ShopifyCLI
  module Theme
    module DevServer
      module Cdn
        class CdnHelperTest < Minitest::Test
          include Cdn::CdnHelper

          def setup
            super

            @env = {
              "REQUEST_METHOD" => "get",
              "rack.input" => body_stream,
            }
            @headers = {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            }
            @uri = URI("http://cdn.shopify/assets/base.css")
          end

          def test_proxy_request
            expected_code = "200"
            expected_content = "<expected content>"
            expected_headers = {
              "Content-Type" => "text/css",
              "Content-Length" => "42",
            }

            stub_request(:get, "https://cdn.shopify/assets/base.css")
              .with(body: body_stream.read, headers: @headers)
              .to_return(status: 200,
                         body: expected_content,
                         headers: expected_headers)

            actual_response = proxy_request(@env, @uri, theme)
            expected_response = [expected_code, expected_headers, [expected_content]]

            assert_equal(expected_response, actual_response)
          end

          private

          def theme
            theme_mock = mock("Theme")
            theme_mock.stubs(:shop).returns("my-test-shop.myshopify.com")
            theme_mock
          end

          def body_stream
            body_mock = mock("Body")
            body_mock.stubs(:read).returns("<content>")
            body_mock
          end
        end
      end
    end
  end
end
