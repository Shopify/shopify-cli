# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"
require "rack/mock"

module ShopifyCLI
  module Theme
    module DevServer
      class CdnFontsTest < Minitest::Test
        def test_replace_local_fonts_in_reponse_body
          original_html = <<~HTML
            <html>
              <head>
                <link rel="preload" as="font" href="https://fonts.shopifycdn.com/assistant/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin="">
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link rel="preload" as="font" href="/fonts/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin="">
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_replace_local_fonts_on_same_line
          original_html = <<~HTML
            <html>
              <head>
                <link rel="preload" as="font" href="https://fonts.shopifycdn.com/assistant/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin=""><link rel="preload" as="font" href="https://fonts.shopifycdn.com/assistant/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin="">
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link rel="preload" as="font" href="/fonts/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin=""><link rel="preload" as="font" href="/fonts/assistant_n4.bcd3d09dcb631dec5544b8fb7b154ff234a44630.woff2?hmac=0a2e92d6956b1312ef7d59f4850549a6e43a908ccf24df47f07b0b4c6da5837d" type="font/woff2" crossorigin="">
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_dont_replace_other_assets
          original_html = <<~HTML
            <html>
              <head>
                <script src="https://cdn.shopify.com/s/trekkie.storefront.9f320156b58d74db598714aa83b6a5fbab4d4efb.min.js"></script>
              </head>
            </html>
          HTML
          assert_equal(original_html, serve(original_html).body)
        end

        def test_serve_font_from_fonts_cdn
          expected_body = "<FONT_FILE_FROM_CDN>"

          stub_request(:get, "https://fonts.shopifycdn.com/assistant/font.123.woff2?hmac=456")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 200, body: expected_body, headers: {})

          response = serve(path: "/fonts/font.123.woff2?hmac=456")
          actual_body = response.body

          assert_equal expected_body, actual_body
        end

        def test_404_on_missing_cdn_fonts
          stub_request(:get, "https://fonts.shopifycdn.com/assistant/missing.123.woff2?hmac=456")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 404, body: "Not found", headers: {})

          response = serve(path: "/fonts/missing.123.woff2?hmac=456")

          assert_equal(404, response.status)
          assert_equal("Not found", response.body)
        end

        private

        def serve(response_body = "", path: "/")
          app = lambda do |_env|
            [200, {}, [response_body]]
          end
          stack = CdnFonts.new(app, theme: theme)
          request = Rack::MockRequest.new(stack)
          request.get(path)
        end

        def root
          @root ||= ShopifyCLI::ROOT + "/test/fixtures/theme"
        end

        def theme
          return @theme if @theme
          @theme = Theme.new(nil, root: root)
          @theme.stubs(shop: "my-test-shop.myshopify.com")
          @theme
        end
      end
    end
  end
end
