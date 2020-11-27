require 'test_helper'
require 'shopify-cli/http_request'

module ShopifyCli
  class HttpRequestTest < MiniTest::Test
    def test_makes_http_post_request
      uri = URI.parse("https://example.com")
      body = "body content"
      variables = { var_name: "var_value" }
      headers = { header_name: "header_value" }
      request = stub_request(:post, "https://example.com/")
        .with(
          body: '{"query":"body content","variables":{"var_name":"var_value"}}',
          headers: {
            'Accept' => '*/*',
            'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
            'Content-Type' => 'application/json',
            'User-Agent' => 'Ruby',
            'Header-Name' => 'header_value',
          }
        )

      HttpRequest.post(uri, body, variables, headers)

      assert_requested request
    end
  end
end
