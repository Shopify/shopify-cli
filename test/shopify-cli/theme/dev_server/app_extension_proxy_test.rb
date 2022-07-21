# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/app_extension_dev_server"
require "rack/mock"
require "timecop"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionProxyTest < Minitest::Test
        SECURE_SESSION_ID = "deadbeef"

        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/extension"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = DevelopmentTheme.new(@ctx, root: root)
          @extension = AppExtension.new(@ctx, root: root, id: 1234)

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")
          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("123456789")
          @proxy = AppExtensionProxy.new(@ctx, extension: @extension, theme: @theme)
        end

        def test_pass_templates_in_cookie_to_storefront
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          ShopifyCLI::DB
            .stubs(:get)
            .with(:storefront_renderer_production_exchange_token)
            .returns("TOKEN")

          stub_request(:post, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              body: {
                "_method" => "GET",
                "replace_extension_templates" => {
                  "blocks" => {
                    "blocks/block2.liquid" => @theme["blocks/block2.liquid"].read,
                  },
                },
              },
              headers: {
                "Accept-Encoding" => "none",
                "Authorization" => "Bearer TOKEN",
                "Content-Type" => "application/x-www-form-urlencoded",
                "Cookie" => http_cookie,
                "Host" => "dev-theme-server-store.myshopify.com",
                "X-Forwarded-For" => "",
                "User-Agent" => "Shopify CLI",
              }
            )
            .to_return(status: 200, body: "PROXY RESPONSE")

          stub_session_id_request
          response = request.get("/", "HTTP_COOKIE" => http_cookie)

          assert_equal("PROXY RESPONSE", response.body)
        end

        private

        def request
          Rack::MockRequest.new(@proxy)
        end

        def default_proxy_headers
          {
            "Accept-Encoding" => "none",
            "Cookie" => "_secure_session_id=#{SECURE_SESSION_ID}",
            "Host" => "dev-theme-server-store.myshopify.com",
            "X-Forwarded-For" => "",
            "User-Agent" => "Shopify CLI",
          }
        end

        def stub_session_id_request
          stub_request(:head, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0&preview_theme_id=123456789")
            .with(
              headers: {
                "Host" => "dev-theme-server-store.myshopify.com",
              }
            )
            .to_return(
              status: 200,
              headers: {
                "Set-Cookie" => "_secure_session_id=#{SECURE_SESSION_ID}",
              }
            )
        end

        def http_cookie(hot_reload_files = "blocks/block2.liquid")
          cookie = [
            "cart_currency=EUR",
            "storefront_digest=123",
            "hot_reload_files=#{hot_reload_files}",
            "_secure_session_id=#{SECURE_SESSION_ID}",
          ]
          cookie.join("; ")
        end
      end
    end
  end
end
