require 'base64'
require 'digest'
require 'json'
require 'net/http'
require 'securerandom'
require 'openssl'
require 'shopify_cli'
require 'socket'
require 'uri'

module ShopifyCli
  class OAuth
    include SmartProperties
    include Helpers::OS

    class Error < StandardError; end

    DEFAULT_PORT = 3456
    REDIRECT_HOST = "http://app-cli-loopback.shopifyapps.com:#{DEFAULT_PORT}"
    TEMPLATE = %{HTTP/1.1 200
      Content-Type: text/html

      <!DOCTYPE html>
      <html>
      <head>
        <title>%{title}</title>
      </head>
      <body>
        <h1 style="color: #%{color};">%{message}</h1>
        %{autoclose}
      </body>
      </html>
    }
    AUTOCLOSE_TEMPLATE = %{
      <script>
        setTimeout(function() { window.close(); }, 3000)
      </script>
    }
    SUCCESS_RESP = 'Authenticated Successfully, this page will close shortly.'
    INVALID_STATE_RESP = 'Anti-forgery state token does not match the initial request.'

    property! :ctx
    property! :service, accepts: String
    property! :client_id, accepts: String
    property! :scopes
    property :store, default: Helpers::Store.new
    property :secret, accepts: String
    property :request_exchange, accepts: String
    property :options, default: {}, accepts: Hash
    property :auth_path, default: "/authorize", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }
    property :token_path, default: "/token", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }
    property :state_token, accepts: String, default: SecureRandom.hex(30)
    property :code_verifier, accepts: String, default: SecureRandom.hex(30)

    def authenticate(url)
      return if refresh_exchange_token(url)
      return if refresh_access_token(url)
      initiate_authentication(url)
      request_access_token(url, code: receive_access_code)
      request_exchange_token(url) if should_exchange
    end

    def code_challenge
      @code_challenge ||= Base64.urlsafe_encode64(
        OpenSSL::Digest::SHA256.digest(code_verifier),
        padding: false,
      )
    end

    private

    def initiate_authentication(url)
      listen_local
      params = {
        client_id: client_id,
        scope: scopes,
        redirect_uri: REDIRECT_HOST,
        state: state_token,
        response_type: :code,
      }
      params.merge!(challange_params) if secret.nil?
      uri = URI.parse("#{url}#{auth_path}")
      uri.query = URI.encode_www_form(params.merge(options))
      open_url!(ctx, uri)
    end

    def listen_local
      server = TCPServer.new('127.0.0.1', DEFAULT_PORT)
      @server_thread ||= Thread.new do
        Thread.current.abort_on_exception = true
        begin
          socket = server.accept
          query = Hash[URI.decode_www_form(socket.gets.split[1][2..-1])]
          if !query['error'].nil?
            respond_with(socket, 400, "Invalid Request: #{query['error_description']}")
          elsif query['state'] != state_token
            query.merge!('error' => 'invalid_state', 'error_description' => INVALID_STATE_RESP)
            respond_with(socket, 403, INVALID_STATE_RESP)
          else
            respond_with(socket, 200, SUCCESS_RESP)
          end
          query
        ensure
          socket.close_write
          server.close
        end
      end
    end

    def receive_access_code
      @access_code ||= begin
        server = @server_thread.join(60)
        raise Error, 'Timed out while waiting for response from shopify' if server.nil?
        query = server.value
        raise Error, query['error_description'] unless query['error'].nil?
        query['code']
      end
    end

    def request_access_token(url, code:)
      resp = post_token_request(
        "#{url}#{token_path}",
        {
          grant_type: :authorization_code,
          code: code,
          redirect_uri: REDIRECT_HOST,
          client_id: client_id,
        }.merge(confirmation_param)
      )
      store.set(
        "#{service}_access_token".to_sym => resp['access_token'],
        "#{service}_refresh_token".to_sym => resp['refresh_token'],
      )
    end

    def refresh_access_token(url)
      return false if !store.exists?("#{service}_access_token".to_sym) ||
        !store.exists?("#{service}_refresh_token".to_sym)
      refresh_token(url)
      request_exchange_token(url) if should_exchange
      true
    rescue
      store.del("#{service}_access_token".to_sym, "#{service}_refresh_token".to_sym)
      false
    end

    def refresh_token(url)
      resp = post_token_request(
        "#{url}#{token_path}",
        grant_type: :refresh_token,
        access_token: store.get("#{service}_access_token".to_sym),
        refresh_token: store.get("#{service}_refresh_token".to_sym),
        client_id: client_id,
      )
      store.set(
        "#{service}_access_token".to_sym => resp['access_token'],
        "#{service}_refresh_token".to_sym => resp['refresh_token'],
      )
    end

    def refresh_exchange_token(url)
      return false if !should_exchange || !store.exists?("#{service}_exchange_token".to_sym)
      request_exchange_token(url)
      true
    rescue
      store.del("#{service}_exchange_token".to_sym)
      false
    end

    def request_exchange_token(url)
      resp = post_token_request(
        "#{url}#{token_path}",
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: request_exchange,
        scope: scopes,
        subject_token: store.get("#{service}_access_token".to_sym),
      )
      store.set("#{service}_exchange_token".to_sym => resp['access_token'])
    end

    def post_token_request(url, params)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request['User-Agent'] = "Shopify App CLI #{::ShopifyCli::VERSION}"
      request.body = URI.encode_www_form(params)
      res = https.request(request)
      raise Error, JSON.parse(res.body)['error_description'] unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end

    def respond_with(resp, status, message)
      successful = status == 200
      locals = {
        status: status,
        message: message,
        color: successful ? 'black' : 'red',
        title: successful ? 'Authenticate Successfully' : 'Failed to Authenticate',
        autoclose: successful ? AUTOCLOSE_TEMPLATE : '',
      }
      resp.print(format(TEMPLATE, locals))
    end

    def challange_params
      {
        code_challenge: code_challenge,
        code_challenge_method: 'S256',
      }
    end

    def confirmation_param
      if secret.nil?
        { code_verifier: code_verifier }
      else
        { client_secret: secret }
      end
    end

    def should_exchange
      !request_exchange.nil? && !request_exchange.empty?
    end
  end
end
