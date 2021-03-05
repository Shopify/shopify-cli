require "test_helper"

module ShopifyCli
  class IdentityAuthTest < MiniTest::Test
    SHOPIFY_SCOPES = %w[https://api.shopify.com/auth/shop.admin.graphql https://api.shopify.com/auth/shop.admin.themes]
    PARTNER_SCOPES = %w[https://api.shopify.com/auth/partners.app.cli.access]

    def test_authenticate
      endpoint = "https://accounts.shopify.com/oauth"
      client_id = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
      partner_audience = "271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6"
      shopify_audience = "7ee65a63608843c577db8b23c4d7316ea0a01bd2f7594f8a9c06ea668c1b775c"
      client = oauth
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client_id,
        scope: scopes(SHOPIFY_SCOPES + PARTNER_SCOPES),
        redirect_uri: IdentityAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: IdentityAuth::REDIRECT_HOST,
        client_id: client_id,
        code_verifier: client.code_verifier,
      }

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      partners_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: partner_audience,
        scope: scopes(PARTNER_SCOPES),
        subject_token: "accesstoken123",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(partners_token_query))
        .to_return(status: 200, body: '{"access_token":"partnerexchangetoken123"}', headers: {})

      shopify_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: shopify_audience,
        scope: scopes(SHOPIFY_SCOPES),
        subject_token: "accesstoken123",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(shopify_token_query))
        .to_return(status: 200, body: '{"access_token":"shopifyexchangetoken123"}', headers: {})

      client.authenticate
      assert_equal("accesstoken123", client.store.get(:identity_access_token))
      assert_equal("refreshtoken123", client.store.get(:identity_refresh_token))
      assert_equal("partnerexchangetoken123", client.store.get(:partners_exchange_token))
      assert_equal("shopifyexchangetoken123", client.store.get(:shopify_exchange_token))
    end

    def test_refresh_exchange_token
      endpoint = "https://accounts.shopify.com/oauth"
      client_id = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
      partner_audience = "271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6"
      shopify_audience = "7ee65a63608843c577db8b23c4d7316ea0a01bd2f7594f8a9c06ea668c1b775c"
      client = oauth(request_exchange: "123")
      client.store.set(
        identity_access_token: "accesstoken123",
        identity_refresh_token: "refreshtoken123",
        partners_exchange_token: "partnerexchangetoken123",
        shopify_exchange_token: "shopifyexchangetoken123"
      )

      partners_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: partner_audience,
        scope: scopes(PARTNER_SCOPES),
        subject_token: "accesstoken123",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(partners_token_query))
        .to_return(status: 200, body: '{"access_token":"partnerexchangetoken456"}', headers: {})

      shopify_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: shopify_audience,
        scope: scopes(SHOPIFY_SCOPES),
        subject_token: "accesstoken123",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(shopify_token_query))
        .to_return(status: 200, body: '{"access_token":"shopifyexchangetoken456"}', headers: {})

      client.authenticate
      assert_equal("partnerexchangetoken456", client.store.get(:partners_exchange_token))
      assert_equal("shopifyexchangetoken456", client.store.get(:shopify_exchange_token))
    end

    def test_refresh_access_token_fallback
      endpoint = "https://accounts.shopify.com/oauth"
      client_id = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
      partner_audience = "271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6"
      shopify_audience = "7ee65a63608843c577db8b23c4d7316ea0a01bd2f7594f8a9c06ea668c1b775c"
      client = oauth(request_exchange: "123")
      client.store.set(
        identity_access_token: "accesstoken123",
        identity_refresh_token: "refreshtoken123",
        partners_exchange_token: "partnerexchangetoken123",
        shopify_exchange_token: "shopifyexchangetoken123",
      )

      partners_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: partner_audience,
        scope: scopes(PARTNER_SCOPES),
        subject_token: "accesstoken123",
      }

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(partners_token_query))
        .to_return(status: 403)

      shopify_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: shopify_audience,
        scope: scopes(SHOPIFY_SCOPES),
        subject_token: "accesstoken123",
      }

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(shopify_token_query))
        .to_return(status: 403)

      token_query = {
        grant_type: :refresh_token,
        access_token: "accesstoken123",
        refresh_token: "refreshtoken123",
        client_id: client_id,
      }
      token_resp = {
        access_token: "accesstoken456",
        refresh_token: "refreshtoken456",
      }.to_json

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      partner_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: partner_audience,
        scope: scopes(PARTNER_SCOPES),
        subject_token: "accesstoken456",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(partner_token_query))
        .to_return(status: 200, body: '{"access_token":"partnerexchangetoken456"}', headers: {})

      shopify_token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: shopify_audience,
        scope: scopes(SHOPIFY_SCOPES),
        subject_token: "accesstoken456",
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(shopify_token_query))
        .to_return(status: 200, body: '{"access_token":"shopifyexchangetoken456"}', headers: {})

      client.authenticate
      assert_equal("accesstoken456", client.store.get(:identity_access_token))
      assert_equal("refreshtoken456", client.store.get(:identity_refresh_token))
      assert_equal("partnerexchangetoken456", client.store.get(:partners_exchange_token))
      assert_equal("shopifyexchangetoken456", client.store.get(:shopify_exchange_token))
    end

    def test_authenticate_with_invalid_request
      endpoint = "https://accounts.shopify.com/oauth"
      client = oauth
      @context.expects(:open_url!)
      stub_server(client, {
        "error" => "err",
        "error_description" => "error",
      })
      stub_request(:post, "#{endpoint}/authorize")
      assert_raises IdentityAuth::Error do
        client.authenticate
      end
    end

    def test_authenticate_with_invalid_code
      endpoint = "https://accounts.shopify.com/oauth"
      client_id = "fbdb2649-e327-4907-8f67-908d24cfd7e3"
      code_verifier = "123456"
      client = oauth(secret: "secret")
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client_id,
        scope: scopes(SHOPIFY_SCOPES + PARTNER_SCOPES),
        redirect_uri: IdentityAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: IdentityAuth::REDIRECT_HOST,
        client_id: client_id,
        code_verifier: code_verifier,
      }

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(
          status: 400,
          body: '{ "error": "invalid_code", "error_description": "your code has expired or is invalid" }',
          headers: {},
        )

      assert_raises IdentityAuth::Error do
        client.authenticate
      end
    end

    private

    def oauth(*)
      db = ShopifyCli::DB.new(path: File.join(ShopifyCli::TEMP_DIR, ".test_db.pstore"))
      db.clear
      IdentityAuth.new(ctx: @context, store: db, code_verifier: "123456")
    end

    def stub_auth_response(client)
      stub_server(client, {
        "code" => "mycode",
        "state" => client.state_token,
      })
    end

    def stub_server(client, resp)
      server = mock
      client.stubs(:server).returns(server)
      server.expects(:start)
      client.response_query = resp
    end

    def token_resp
      {
        access_token: "accesstoken123",
        refresh_token: "refreshtoken123",
      }.to_json
    end

    def scopes(additional_scopes = [])
      (["openid"] + additional_scopes).tap do |result|
        result << "employee" if ShopifyCli::Shopifolk.acting_as_shopify_organization?
      end.join(" ")
    end
  end
end
