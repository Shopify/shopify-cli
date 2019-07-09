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

    class Error < StandardError; end

    REDIRECT_HOST = "http://localhost"
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

    property! :client_id, accepts: String
    property! :scopes
    property :secret, accepts: String
    property :port, default: 3456, accepts: Integer
    property :options, default: {}, accepts: Hash
    property :auth_path, default: "/authorize", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }
    property :token_path, default: "/token", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }

    def authenticate(url)
      listen_local
      initiate_authentication(url)
      res = request_token(url, code: receive_access_code)
      raise Error, JSON.parse(res.body)['error_description'] unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)["access_token"]
    end

    def redirect_uri
      "#{REDIRECT_HOST}:#{port}/"
    end

    def state_token
      @state_token ||= SecureRandom.hex(30)
    end

    def code_verifier
      @code_verifier ||= SecureRandom.hex(30)
    end

    def code_challenge
      @code_challenge ||= Base64.urlsafe_encode64(
        OpenSSL::Digest::SHA256.digest(code_verifier),
        padding: false,
      )
    end

    private

    def initiate_authentication(url)
      params = {
        client_id: client_id,
        scope: scopes,
        redirect_uri: redirect_uri,
        state: state_token,
        response_type: :code,
      }
      params.merge!(challange_params) if secret.nil?
      uri = URI.parse("#{url}#{auth_path}")
      uri.query = URI.encode_www_form(params.merge(options))
      CLI::Kit::System.system("open '#{uri}'")
    end

    def listen_local
      server = TCPServer.new('localhost', port)
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
        query = @server_thread.join(5).value
        raise Error, query['error_description'] unless query['error'].nil?
        query['code']
      end
    end

    def request_token(url, code:)
      uri = URI.parse("#{url}#{token_path}")
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request['User-Agent'] = "Shopify App CLI #{::ShopifyCli::VERSION}"
      params = {
        grant_type: :authorization_code,
        code: code,
        redirect_uri: redirect_uri,
        client_id: client_id,
      }.merge(confirmation_param)
      request.body = URI.encode_www_form(params)
      https.request(request)
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
  end
end
