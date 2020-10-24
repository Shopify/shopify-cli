require 'test_helper'

module ShopifyCli
  class OAuthTest < MiniTest::Test
    def test_new
      client = oauth
      assert_equal 'test', client.service
      assert_equal 'key', client.client_id
      assert_equal 'test,one', client.scopes
      assert_nil(client.secret)
      assert_equal({}, client.options)

      client = oauth(secret: 'secret', options: { foo: :bar })
      assert_equal 'key', client.client_id
      assert_equal 'test,one', client.scopes
      assert_equal 'secret', client.secret
      assert_equal({ foo: :bar }, client.options)
    end

    def test_authenticate_with_secret
      endpoint = "https://example.com/auth"
      client = oauth(secret: 'secret')
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: OAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: OAuth::REDIRECT_HOST,
        client_id: client.client_id,
        client_secret: 'secret',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      client.authenticate(endpoint)
      assert_equal('accesstoken123', client.store.get(:test_access_token))
      assert_equal('refreshtoken123', client.store.get(:test_refresh_token))
    end

    def test_authenticate_without_secret
      endpoint = "https://example.com/auth"
      client = oauth
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: OAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: OAuth::REDIRECT_HOST,
        client_id: client.client_id,
        code_verifier: client.code_verifier,
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      client.authenticate(endpoint)
      assert_equal('accesstoken123', client.store.get(:test_access_token))
      assert_equal('refreshtoken123', client.store.get(:test_refresh_token))
    end

    def test_request_exchange_token
      endpoint = "https://example.com/auth"
      client = oauth(request_exchange: '123')
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: OAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: OAuth::REDIRECT_HOST,
        client_id: client.client_id,
        code_verifier: client.code_verifier,
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client.client_id,
        audience: '123',
        scope: client.scopes,
        subject_token: 'accesstoken123',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: '{"access_token":"exchangetoken123"}', headers: {})

      client.authenticate(endpoint)
      assert_equal('accesstoken123', client.store.get(:test_access_token))
      assert_equal('refreshtoken123', client.store.get(:test_refresh_token))
      assert_equal('exchangetoken123', client.store.get(:test_exchange_token))
    end

    def test_refresh_exchange_token
      endpoint = "https://example.com/auth"
      client = oauth(request_exchange: '123')
      client.store.set(
        test_access_token: 'accesstoken123',
        test_refresh_token: 'refreshtoken123',
        test_exchange_token: 'exchangetoken123',
      )

      token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client.client_id,
        audience: '123',
        scope: client.scopes,
        subject_token: 'accesstoken123',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: '{"access_token":"exchangetoken456"}', headers: {})

      client.authenticate(endpoint)
      assert_equal('exchangetoken456', client.store.get(:test_exchange_token))
    end

    def test_refresh_access_token_fallback
      endpoint = "https://example.com/auth"
      client = oauth(request_exchange: '123')
      client.store.set(
        test_access_token: 'accesstoken123',
        test_refresh_token: 'refreshtoken123',
        test_exchange_token: 'exchangetoken123',
      )

      token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client.client_id,
        audience: '123',
        scope: client.scopes,
        subject_token: 'accesstoken123',
      }

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 403)

      token_query = {
        grant_type: :refresh_token,
        access_token: 'accesstoken123',
        refresh_token: 'refreshtoken123',
        client_id: client.client_id,
      }

      token_resp = {
        access_token: "accesstoken456",
        refresh_token: "refreshtoken456",
      }.to_json

      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: token_resp, headers: {})

      token_query = {
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client.client_id,
        audience: '123',
        scope: client.scopes,
        subject_token: 'accesstoken456',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: '{"access_token":"exchangetoken456"}', headers: {})

      client.authenticate(endpoint)
      assert_equal('accesstoken456', client.store.get(:test_access_token))
      assert_equal('refreshtoken456', client.store.get(:test_refresh_token))
      assert_equal('exchangetoken456', client.store.get(:test_exchange_token))
    end

    def test_authenticate_with_invalid_request
      endpoint = "https://example.com/auth"
      client = oauth
      @context.expects(:open_url!)
      stub_server(client, {
        'error' => 'err',
        'error_description' => 'error',
      })
      stub_request(:post, "#{endpoint}/authorize")
      assert_raises OAuth::Error do
        client.authenticate(endpoint)
      end
    end

    def test_authenticate_with_invalid_code
      endpoint = "https://example.com/auth"
      client = oauth(secret: 'secret')
      @context.expects(:open_url!)
      stub_auth_response(client)

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: OAuth::REDIRECT_HOST,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: OAuth::REDIRECT_HOST,
        client_id: client.client_id,
        client_secret: 'secret',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(
          status: 400,
          body: '{ "error": "invalid_code", "error_description": "your code has expired or is invalid" }',
          headers: {},
        )

      assert_raises OAuth::Error do
        client.authenticate(endpoint)
      end
    end

    private

    def oauth(**args)
      db = ShopifyCli::DB.new(path: File.join(ShopifyCli::TEMP_DIR, ".test_db.pstore"))
      db.clear
      OAuth.new({
        ctx: @context,
        service: 'test',
        client_id: 'key',
        scopes: 'test,one',
        store: db,
      }.merge(args))
    end

    def stub_auth_response(client)
      stub_server(client, {
        'code' => 'mycode',
        'state' => client.state_token,
      })
    end

    def stub_server(client, resp)
      server = Object.new
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
  end
end
