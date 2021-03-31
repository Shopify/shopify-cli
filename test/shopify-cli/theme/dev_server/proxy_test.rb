# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"
require "rack/mock"

class ProxyTest < Minitest::Test
  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @ctx = TestHelpers::FakeContext.new(root: config.root)
    @theme = ShopifyCli::Theme::DevServer::Theme.new(@ctx, config)
    @proxy = ShopifyCli::Theme::DevServer::Proxy.new(@ctx, @theme)

    ShopifyCli::DB.stubs(:exists?).with(:shop).returns(true)
    ShopifyCli::DB
      .stubs(:get)
      .with(:shop)
      .returns("dev-theme-server-store.myshopify.com")
    ShopifyCli::DB
      .stubs(:get)
      .with(:development_theme_id)
      .returns("123456789")
  end

  def test_form_data_is_proxied_to_request
    stub_request(:post, "https://dev-theme-server-store.myshopify.com/password?_fd=0&pb=0")
      .with(
        body: {
          "form_type" => "storefront_password",
          "password" => "notapassword",
        },
        headers: {
          "Accept-Encoding" => "none",
          "Content-Type" => "application/x-www-form-urlencoded",
          "Cookie" => "; _secure_session_id=",
          "Host" => "dev-theme-server-store.myshopify.com",
          "X-Forwarded-For" => "",
        }
      )
      .to_return(status: 200)

    stub_session_id_request

    request.post("/password", params: {
      "form_type" => "storefront_password",
      "password" => "notapassword",
    })
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
      })

    stub_session_id_request
    response = request.get("/")

    ShopifyCli::Theme::DevServer::HOP_BY_HOP_HEADERS.each do |header|
      assert(response.headers[header].nil?)
    end
  end

  def test_pass_pending_files_to_storefront
    ShopifyCli::DB
      .stubs(:get)
      .with(:shop)
      .returns("dev-theme-server-store.myshopify.com")

    ShopifyCli::DB
      .stubs(:get)
      .with(:storefront_renderer_production_exchange_token)
      .returns("TOKEN")

    @theme.stubs(:pending_files).returns([
      mock(relative_path: "layout/theme.liquid", read: "CONTENT"),
    ])

    stub_request(:post, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0")
      .with(
        body: {
          "_method" => "GET",
          "replace_templates" => { "layout/theme.liquid" => "CONTENT" },
        },
        headers: {
          "Accept-Encoding" => "none",
          "Authorization" => "Bearer TOKEN",
          "Content-Type" => "application/x-www-form-urlencoded",
          "Cookie" => "; _secure_session_id=",
          "Host" => "dev-theme-server-store.myshopify.com",
          "X-Forwarded-For" => "",
        }
      )
      .to_return(status: 200, body: "PROXY RESPONSE")

    stub_session_id_request
    response = request.get("/")

    assert_equal("PROXY RESPONSE", response.body)
  end

  def test_requires_exchange_token
    ShopifyCli::DB
      .stubs(:get)
      .with(:storefront_renderer_production_exchange_token)
      .returns(nil)

    @theme.stubs(:pending_files).returns([
      stub(relative_path: "layout/theme.liquid", read: "CONTENT"),
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
      "Cookie" => "; _secure_session_id=",
      "Host" => "dev-theme-server-store.myshopify.com",
      "X-Forwarded-For" => "",
    }
  end

  def stub_session_id_request
    stub_request(:get, "https://dev-theme-server-store.myshopify.com/?_fd=0&pb=0&preview_theme_id=123456789")
      .with(
        headers: {
          "Accept" => "*/*",
          "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Host" => "dev-theme-server-store.myshopify.com",
          "User-Agent" => "Ruby",
        }
      )
      .to_return(status: 200, body: "", headers: {})
  end
end
