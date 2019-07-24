require 'test_helper'

module ShopifyCli
  class OAuthTest < MiniTest::Test
    include TestHelpers::Project
    include TestHelpers::Constants

    def test_new
      client = OAuth.new(client_id: 'key', scopes: 'test,one')
      assert_equal 'key', client.client_id
      assert_equal 'test,one', client.scopes
      assert_nil(client.secret)
      assert_equal 3456, client.port
      assert_equal({}, client.options)

      client = OAuth.new(client_id: 'key', scopes: 'test,one', port: 9876, secret: 'secret', options: { foo: :bar })
      assert_equal 'key', client.client_id
      assert_equal 'test,one', client.scopes
      assert_equal 9876, client.port
      assert_equal 'secret', client.secret
      assert_equal({ foo: :bar }, client.options)
    end

    def test_authenticate_with_secret
      endpoint = "https://example.com/auth"
      client = OAuth.new(client_id: 'key', scopes: 'test,one', secret: 'secret')
      CLI::Kit::System.expects(:system).with do |param|
        auth_repsonse(client, endpoint, param)
      end

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: client.redirect_uri,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: client.redirect_uri,
        client_id: client.client_id,
        client_secret: 'secret',
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: '{ "access_token": "accesstoken123" }', headers: {})

      assert_equal 'accesstoken123', client.authenticate(endpoint)
    end

    def test_authenticate_pkce
      endpoint = "https://example.com/auth"
      client = OAuth.new(client_id: 'key', scopes: 'test,one')
      CLI::Kit::System.expects(:system).with do |param|
        auth_repsonse(client, endpoint, param)
      end

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: client.redirect_uri,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: client.redirect_uri,
        client_id: client.client_id,
        code_verifier: client.code_verifier,
      }
      stub_request(:post, "#{endpoint}/token")
        .with(body: URI.encode_www_form(token_query))
        .to_return(status: 200, body: '{ "access_token": "accesstoken123" }', headers: {})

      assert_equal 'accesstoken123', client.authenticate(endpoint)
    end

    def test_authenticate_with_invalid_request
      endpoint = "https://example.com/auth"
      client = OAuth.new(client_id: 'key', scopes: 'test,one')
      CLI::Kit::System.stubs(:system).with do |_param|
        WebMock.disable!
        https = Net::HTTP.new('localhost', 3456)
        request = Net::HTTP::Get.new("/?error=err&error_description=error")
        https.request(request)
        WebMock.enable!
        true
      end
      stub_request(:post, "#{endpoint}/authorize")
      assert_raises OAuth::Error do
        client.authenticate(endpoint)
      end
    end

    def test_authenticate_with_invalid_state
      endpoint = "https://example.com/auth"
      client = OAuth.new(client_id: 'key', scopes: 'test,one')
      CLI::Kit::System.stubs(:system).with do |_param|
        WebMock.disable!
        https = Net::HTTP.new('localhost', 3456)
        request = Net::HTTP::Get.new("/?code=mycode&state=notyourstate")
        https.request(request)
        WebMock.enable!
        true
      end
      stub_request(:post, "#{endpoint}/authorize")
      assert_raises OAuth::Error do
        client.authenticate(endpoint)
      end
    end

    def test_authenticate_with_invalid_code
      endpoint = "https://example.com/auth"
      client = OAuth.new(client_id: 'key', scopes: 'test,one', secret: 'secret')
      CLI::Kit::System.expects(:system).with do |param|
        auth_repsonse(client, endpoint, param)
      end

      authorize_query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: client.redirect_uri,
        state: client.state_token,
        response_type: :code,
      }
      stub_request(:post, "#{endpoint}/authorize?#{URI.encode_www_form(authorize_query)}")

      token_query = {
        grant_type: :authorization_code,
        code: "mycode",
        redirect_uri: client.redirect_uri,
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

    def auth_repsonse(client, endpoint, param)
      query = {
        client_id: client.client_id,
        scope: client.scopes,
        redirect_uri: client.redirect_uri,
        state: client.state_token,
        response_type: :code,
      }
      if client.secret.nil?
        query.merge!(
          code_challenge: client.code_challenge,
          code_challenge_method: 'S256',
        )
      end
      command = "open '#{endpoint}/authorize?#{URI.encode_www_form(query)}'"
      if command == param
        WebMock.disable!
        https = Net::HTTP.new('localhost', 3456)
        request = Net::HTTP::Get.new("/?code=mycode&state=#{client.state_token}")
        https.request(request)
        WebMock.enable!
      end
      command == param
    end
  end
end
