# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/theme_dev_server"
require "rack/mock"
require "timecop"

module ShopifyCLI
  module Theme
    module DevServer
      class ThemeProxyTest < Minitest::Test
        SECURE_SESSION_ID = "deadbeef"

        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = DevelopmentTheme.new(@ctx, root: root)
          @syncer = stub(pending_updates: [])

          ShopifyCLI::DB.stubs(:exists?).with(:shop).returns(true)
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")
          ShopifyCLI::DB
            .stubs(:get)
            .with(:development_theme_id)
            .returns("123456789")
          @proxy = ThemeProxy.new(@ctx, theme: @theme, syncer: @syncer)
        end

        def test_pass_pending_templates_to_storefront
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          ShopifyCLI::DB
            .stubs(:get)
            .with(:storefront_renderer_production_exchange_token)
            .returns("TOKEN")

          @syncer.expects(:pending_updates).returns([
            @theme["layout/theme.liquid"],
            @theme["assets/theme.css"], # Should not be included in the POST body
          ])

          stub_request(:post, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              body: {
                "_method" => "GET",
                "replace_templates" => {
                  "layout/theme.liquid" => @theme["layout/theme.liquid"].read,
                },
              },
              headers: {
                "Accept-Encoding" => "none",
                "Authorization" => "Bearer TOKEN",
                "Content-Type" => "application/x-www-form-urlencoded",
                "Cookie" => "_secure_session_id=#{SECURE_SESSION_ID}",
                "Host" => "dev-theme-server-store.myshopify.com",
                "X-Forwarded-For" => "",
                "User-Agent" => "Shopify CLI",
              }
            )
            .to_return(status: 200, body: "PROXY RESPONSE")

          stub_session_id_request
          response = request.get("/")

          assert_equal("PROXY RESPONSE", response.body)
        end

        def test_patching_store_urls
          ShopifyCLI::DB
            .stubs(:get)
            .with(:storefront_renderer_production_exchange_token)
            .returns("TOKEN")

          @syncer.stubs(:pending_updates).returns([@theme["layout/theme.liquid"]])
          @proxy.stubs(:host).returns("127.0.0.1:9292")

          stub_request(:post, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              body: {
                "_method" => "GET",
                "replace_templates" => {
                  "layout/theme.liquid" => @theme["layout/theme.liquid"].read,
                },
              },
              headers: { "User-Agent" => "Shopify CLI" }
            )
            .to_return(status: 200, body: <<-PROXY_RESPONSE)
              <html>
                <body>
                  <h1>My dev-theme-server-store.myshopify.com store!</h1>

                  <a data-attr-1="http://dev-theme-server-store.myshopify.com/link">1</a>
                  <a data-attr-2="https://dev-theme-server-store.myshopify.com/link">2</a>
                  <a data-attr-3="//dev-theme-server-store.myshopify.com/link">3</a>
                  <a data-attr-4='//dev-theme-server-store.myshopify.com/li"nk'>4</a>

                  <a href="http://dev-theme-server-store.myshopify.com/link">5</a>
                  <a href="https://dev-theme-server-store.myshopify.com/link">6</a>
                  <a href="//dev-theme-server-store.myshopify.com/link">7</a>
                </body>
              </html>
            PROXY_RESPONSE

          stub_session_id_request
          response = request.get("/")

          assert_equal(<<-EXPECTED_RESPONSE, response.body)
              <html>
                <body>
                  <h1>My dev-theme-server-store.myshopify.com store!</h1>

                  <a data-attr-1="http://127.0.0.1:9292/link">1</a>
                  <a data-attr-2="http://127.0.0.1:9292/link">2</a>
                  <a data-attr-3="http://127.0.0.1:9292/link">3</a>
                  <a data-attr-4='http://127.0.0.1:9292/li"nk'>4</a>

                  <a href="http://dev-theme-server-store.myshopify.com/link">5</a>
                  <a href="https://dev-theme-server-store.myshopify.com/link">6</a>
                  <a href="//dev-theme-server-store.myshopify.com/link">7</a>
                </body>
              </html>
          EXPECTED_RESPONSE
        end

        def test_do_not_pass_pending_files_to_core
          ShopifyCLI::DB
            .stubs(:get)
            .with(:shop)
            .returns("dev-theme-server-store.myshopify.com")

          ShopifyCLI::DB
            .stubs(:get)
            .with(:storefront_renderer_production_exchange_token)
            .returns("TOKEN")

          # First request marks the endpoint as being served by Core
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/on-core?_fd=0&pb=0")
            .to_return(status: 200, headers: {
              # Doesn't have the x-storefront-renderer-rendered header
            }).times(2)

          stub_session_id_request
          request.get("/on-core")

          # Introduce pending files, but should not hit the POST endpoint
          @syncer.stubs(:pending_updates).returns([
            @theme["layout/theme.liquid"],
          ])
          request.get("/on-core")
        end

        def test_requires_exchange_token
          ShopifyCLI::DB
            .stubs(:get)
            .with(:storefront_renderer_production_exchange_token)
            .returns(nil)

          @syncer.expects(:pending_updates).returns([
            @theme["layout/theme.liquid"],
          ])

          stub_session_id_request
          assert_raises(KeyError) do
            request.get("/")
          end
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
      end
    end
  end
end
