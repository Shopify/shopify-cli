# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"
require "rack/mock"

module ShopifyCLI
  module Theme
    module DevServer
      class CdnAssetsTest < Minitest::Test
        def test_replace_cdn_css_in_reponse_body
          original_html = <<~HTML
            <html>
              <head>
                <link href="//cdn.shopify.com/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all">
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link href="/cdn_asset/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all">
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_replace_cdn_js_in_reponse_body
          original_html = <<~HTML
            <html>
              <head>
                <script src="//cdn.shopify.com/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script>
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <script src="/cdn_asset/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script>
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_replace_two_cdn_css_files_on_same_line
          original_html = <<~HTML
            <html>
              <head>
                <link href="//cdn.shopify.com/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all"><link href="//cdn.shopify.com/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all">
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link href="/cdn_asset/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all"><link href="/cdn_asset/s/files/AAAA/0000/1111/2222/t/3333/assets/base.css" rel="stylesheet" type="text/css" media="all">
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_replace_two_cdn_js_files_on_same_line
          original_html = <<~HTML
            <html>
              <head>
                <script src="//cdn.shopify.com/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script><script src="//cdn.shopify.com/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script>
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <script src="/cdn_asset/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script><script src="/cdn_asset/s/files/AAAAA/0000/1111/2222/t/3333/compiled_assets/script.js"></script>
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_serve_js_asset_from_cdn
          response_body = "<ASSET_FILE_FROM_CDN>" \
                          "//# sourceMappingURL=/script.js.map"
          expected_body = "<ASSET_FILE_FROM_CDN>" \
                          "//# sourceMappingURL=/cdn_asset/script.js.map"

          stub_request(:get, "https://cdn.shopify.com/script.js")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 200, body: response_body, headers: {})

          response = serve(path: "/cdn_asset/script.js")
          actual_body = response.body

          assert_equal expected_body, actual_body
        end

        def test_serve_css_asset_from_cdn
          response_body = "<ASSET_FILE_FROM_CDN>" \
                          "/*# sourceMappingURL=/style.css.map */"
          expected_body = "<ASSET_FILE_FROM_CDN>" \
                          "/*# sourceMappingURL=/cdn_asset/style.css.map */"

          stub_request(:get, "https://cdn.shopify.com/style.css")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 200, body: response_body, headers: {})

          response = serve(path: "/cdn_asset/style.css")
          actual_body = response.body

          assert_equal expected_body, actual_body
        end

        def test_serve_map_from_cdn
          expected_body = "<MAP_FILE_FROM_CDN>"

          stub_request(:get, "https://cdn.shopify.com/s/any/theme.css.min.map")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 200, body: expected_body, headers: {})

          response = serve(path: "/cdn_asset/s/any/theme.css.min.map")
          actual_body = response.body

          assert_equal expected_body, actual_body
        end

        def test_404_on_missing_cdn_asset
          stub_request(:get, "https://cdn.shopify.com/not_found_resource.js")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 404, body: "Not found", headers: {})

          response = serve(path: "/cdn_asset/not_found_resource.js")

          assert_equal(404, response.status)
          assert_equal("Not found", response.body)
        end

        def test_404_on_missing_cdn_map
          stub_request(:get, "https://cdn.shopify.com/s/any/not_found_resource.map")
            .with(headers: {
              "Referer" => "https://my-test-shop.myshopify.com",
              "Transfer-Encoding" => "chunked",
            })
            .to_return(status: 404, body: "Not found", headers: {})

          response = serve(path: "/cdn_asset/s/any/not_found_resource.map")

          assert_equal(404, response.status)
          assert_equal("Not found", response.body)
        end

        private

        def serve(response_body = "", path: "/")
          app = lambda do |_env|
            [200, {}, [response_body]]
          end
          stack = CdnAssets.new(app, theme: theme)
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
