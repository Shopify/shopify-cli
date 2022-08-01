# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server/base_proxy"
require "rack/mock"
require "timecop"

module ShopifyCLI
  module Theme
    module DevServer
      class BaseProxyTest < Minitest::Test
        SECURE_SESSION_ID = "deadbeef"

        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @proxy = FakeBaseProxy.new(@ctx)
        end

        def test_get_is_proxied_to_online_store
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              body: nil,
              headers: default_proxy_headers,
            )
            .to_return(status: 200)

          stub_session_id_request

          request.get("/")
        end

        def test_refreshes_session_cookie_on_expiry
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              body: nil,
              headers: default_proxy_headers,
            )
            .to_return(status: 200)
            .times(2)

          stub_session_id_request
          request.get("/")

          # Should refresh the session cookie after 1 day
          Timecop.freeze(DateTime.now + 1) do # rubocop:disable Style/DateTime
            request.get("/")
          end

          assert_requested(:head,
            "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0&preview_theme_id=123456789",
            times: 2)
        end

        def test_update_session_cookie_when_returned_from_backend
          stub_session_id_request
          new_secure_session_id = "#{SECURE_SESSION_ID}2"

          # POST response returning a new session cookie (Set-Cookie)
          stub_request(:post, "https://dev-theme-server-store.myshopify.com/account/login?_fd=0&pb=0")
            .with(
              headers: {
                "Cookie" => "_secure_session_id=#{SECURE_SESSION_ID}",
              }
            )
            .to_return(
              status: 200,
              body: "",
              headers: {
                "Set-Cookie" => "_secure_session_id=#{new_secure_session_id}",
              }
            )

          # GET / passing the new session cookie
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              headers: {
                "Cookie" => "_secure_session_id=#{new_secure_session_id}",
              }
            )
            .to_return(status: 200)

          request.post("/account/login")
          request.get("/")
        end

        def test_form_data_is_proxied_to_online_store
          stub_request(:post, "https://dev-theme-server-store.myshopify.com/password?_fd=0&pb=0")
            .with(
              body: {
                "form_type" => "storefront_password",
                "password" => "notapassword",
              },
              headers: default_proxy_headers.merge(
                "Content-Type" => "application/x-www-form-urlencoded",
              )
            )
            .to_return(status: 200)

          stub_session_id_request

          request.post("/password", params: {
            "form_type" => "storefront_password",
            "password" => "notapassword",
          })
        end

        def test_multipart_is_proxied_to_online_store
          stub_request(:post, "https://dev-theme-server-store.myshopify.com/cart/add?_fd=0&pb=0")
            .with(
              headers: default_proxy_headers.merge(
                "Content-Length" => "272",
                "Content-Type" => "multipart/form-data; boundary=AaB03x",
              )
            )
            .to_return(status: 200)

          stub_session_id_request

          file = ShopifyCLI::ROOT + "/test/fixtures/theme/assets/theme.css"

          request.post("/cart/add", params: {
            "form_type" => "product",
            "quantity" => 1,
            "file" => Rack::Multipart::UploadedFile.new(file), # To force multipart
          })
        end

        def test_query_parameters_with_two_values
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0&value=A&value=B")
            .with(headers: default_proxy_headers)
            .to_return(status: 200, body: "", headers: {})

          stub_session_id_request

          URI.expects(:encode_www_form)
            .with([[:preview_theme_id, "123456789"], [:_fd, 0], [:pb, 0]])
            .returns("_fd=0&pb=0&preview_theme_id=123456789")

          URI.expects(:encode_www_form)
            .with([["value", "A"], ["value", "B"], [:_fd, 0], [:pb, 0]])
            .returns("_fd=0&pb=0&value=A&value=B")

          request.get("/?value=A&value=B")
        end

        def test_storefront_redirect_headers_are_rewritten
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(headers: default_proxy_headers)
            .to_return(status: 302, headers: {
              "Location" => "https://dev-theme-server-store.myshopify.com/password",
            })

          stub_session_id_request
          response = request.get("/")

          assert_equal("http://127.0.0.1:9292/password", response.headers["Location"])
        end

        def test_non_storefront_redirect_headers_are_not_rewritten
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(headers: default_proxy_headers)
            .to_return(status: 302, headers: {
              "Location" => "https://some-other-site.com/",
            })

          stub_session_id_request
          response = request.get("/")

          assert_equal("https://some-other-site.com/", response.headers["Location"])
        end

        def test_hop_to_hop_headers_are_removed_from_proxied_response
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(headers: default_proxy_headers)
            .to_return(status: 200, headers: {
              "Connection" => 1,
              "Keep-Alive" => 1,
              "Proxy-Authenticate" => 1,
              "Proxy-Authorization" => 1,
              "te" => 1,
              "Trailer" => 1,
              "Transfer-Encoding" => 1,
              "Upgrade" => 1,
              "content-security-policy" => 1,
            })

          stub_session_id_request
          response = request.get("/")

          assert(response.headers.size.zero?)
          HOP_BY_HOP_HEADERS.each do |header|
            assert(response.headers[header].nil?)
          end
        end

        def test_replaces_secure_session_id_cookie
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              headers: {
                "Cookie" => "_secure_session_id=#{SECURE_SESSION_ID}",
              }
            )

          stub_session_id_request
          request.get("/",
            "HTTP_COOKIE" => "_secure_session_id=a12cef")
        end

        def test_appends_secure_session_id_cookie
          stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
            .with(
              headers: {
                "Cookie" => "cart_currency=CAD; secure_customer_sig=; _secure_session_id=#{SECURE_SESSION_ID}",
              }
            )

          stub_session_id_request
          request.get("/",
            "HTTP_COOKIE" => "cart_currency=CAD; secure_customer_sig=")
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

        class FakeBaseProxy < BaseProxy
          def initialize(ctx)
            super(ctx)
            @shop = "dev-theme-server-store.myshopify.com"
            @theme_id = "123456789"
          end
        end
      end
    end
  end
end
