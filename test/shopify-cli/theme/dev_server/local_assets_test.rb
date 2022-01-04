# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"
require "rack/mock"

module ShopifyCLI
  module Theme
    module DevServer
      class LocalAssetsTest < Minitest::Test
        def test_replace_local_assets_in_reponse_body
          original_html = <<~HTML
            <html>
              <head>
                <link rel="stylesheet" href="//cdn.shopify.com/s/files/1/0457/3256/0918/t/2/assets/theme.css?enable_css_minification=1&v=3271603065762738033" />
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link rel="stylesheet" href="/assets/theme.css?enable_css_minification=1&v=3271603065762738033" />
              </head>
            </html>
          HTML
          assert_equal(expected_html, serve(original_html).body)
        end

        def test_replace_local_assets_on_same_line
          original_html = <<~HTML
            <html>
              <head>
                <link rel="stylesheet" href="//cdn.shopify.com/s/files/1/0457/3256/0918/t/2/assets/theme.css?enable_css_minification=1&v=3271603065762738033" /><link rel="stylesheet" href="//cdn.shopify.com/s/files/1/0457/3256/0918/t/2/assets/theme.css?enable_css_minification=1&v=3271603065762738033" />
              </head>
            </html>
          HTML
          expected_html = <<~HTML
            <html>
              <head>
                <link rel="stylesheet" href="/assets/theme.css?enable_css_minification=1&v=3271603065762738033" /><link rel="stylesheet" href="/assets/theme.css?enable_css_minification=1&v=3271603065762738033" />
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

        def test_serve_css_from_disk
          response = serve("<WRONG>", path: "/assets/theme.css")
          assert_equal("text/css", response["Content-Type"])
          assert_equal(
            ::File.read("#{ShopifyCLI::ROOT}/test/fixtures/theme/assets/theme.css"),
            response.body
          )
        end

        def test_serve_js_from_disk
          response = serve("<WRONG>", path: "/assets/theme.js")
          assert_equal("application/javascript", response["Content-Type"])
          assert_equal(
            ::File.read("#{ShopifyCLI::ROOT}/test/fixtures/theme/assets/theme.css"),
            response.body
          )
        end

        def test_404_on_missing_local_assets
          response = serve("<WRONG>", path: "/assets/missing.css")
          assert_equal("text/plain", response["Content-Type"])
          assert_equal("Not found", response.body)
        end

        private

        def serve(response_body, path: "/")
          app = lambda do |_env|
            [200, {}, [response_body]]
          end
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          ctx = TestHelpers::FakeContext.new(root: root)
          theme = Theme.new(ctx, root: root)
          stack = LocalAssets.new(ctx, app, theme: theme)
          request = Rack::MockRequest.new(stack)
          request.get(path)
        end
      end
    end
  end
end
