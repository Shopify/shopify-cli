require "base64"
require "digest"
require "json"
require "net/http"
require "securerandom"
require "openssl"
require "shopify_cli"
require "uri"
require "webrick"

module ShopifyCli
  class OAuth
    include SmartProperties

    autoload :Servlet, "shopify-cli/oauth/servlet"

    class Error < StandardError; end
    LocalRequest = Struct.new(:method, :path, :query, :protocol)

    DEFAULT_PORT = 3456
    REDIRECT_HOST = "http://127.0.0.1:#{DEFAULT_PORT}"

    property! :ctx
    property! :service, accepts: String
    property! :client_id, accepts: String
    property! :scopes
    property :store, default: -> { ShopifyCli::DB.new }
    property :secret, accepts: String
    property :request_exchange, accepts: String
    property :options, default: -> { {} }, accepts: Hash
    property :auth_path, default: "/authorize", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }
    property :token_path, default: "/token", accepts: ->(path) { path.is_a?(String) && path.start_with?("/") }
    property :state_token, accepts: String, default: SecureRandom.hex(30)
    property :code_verifier, accepts: String, default: SecureRandom.hex(30)

    attr_accessor :response_query

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

    def server
      @server ||= begin
        server = WEBrick::HTTPServer.new(
          Port: DEFAULT_PORT,
          Logger: WEBrick::Log.new(File.open(File::NULL, "w")),
          AccessLog: [],
        )
        server.mount("/", Servlet, self, state_token)
        server
      end
    end

    private

    def initiate_authentication(url)
      @server_thread = Thread.new { server.start }
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
      output_authentication_info(uri)
    end

    def output_authentication_info(uri)
      login_location = ctx.message(service == "admin" ? "core.oauth.location.admin" : "core.oauth.location.partner")
      ctx.puts(ctx.message("core.oauth.authentication_required", login_location))
      ctx.open_url!(uri)
    end

    def receive_access_code
      @access_code ||= begin
        @server_thread.join(240)
        raise Error, ctx.message("core.oauth.error.timeout") if response_query.nil?
        raise Error, response_query["error_description"] unless response_query["error"].nil?
        response_query["code"]
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
        "#{service}_access_token".to_sym => resp["access_token"],
        "#{service}_refresh_token".to_sym => resp["refresh_token"],
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
        "#{service}_access_token".to_sym => resp["access_token"],
        "#{service}_refresh_token".to_sym => resp["refresh_token"],
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
      store.set("#{service}_exchange_token".to_sym => resp["access_token"])
    end

    def post_token_request(url, params)
      uri = URI.parse(url)
      https = Net::HTTP.new(uri.host, uri.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(uri.path)
      request["User-Agent"] = "Shopify App CLI #{::ShopifyCli::VERSION}"
      request.body = URI.encode_www_form(params)
      res = https.request(request)
      raise Error, JSON.parse(res.body)["error_description"] unless res.is_a?(Net::HTTPSuccess)
      JSON.parse(res.body)
    end

    def challange_params
      {
        code_challenge: code_challenge,
        code_challenge_method: "S256",
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
