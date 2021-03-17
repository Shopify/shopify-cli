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
  class IdentityAuth
    include SmartProperties

    class Error < StandardError; end
    LocalRequest = Struct.new(:method, :path, :query, :protocol)
    LOCAL_DEBUG = "SHOPIFY_APP_CLI_LOCAL"

    DEFAULT_PORT = 3456
    REDIRECT_HOST = "http://127.0.0.1:#{DEFAULT_PORT}"
    SHOPIFY_SCOPES = %w[https://api.shopify.com/auth/shop.admin.graphql https://api.shopify.com/auth/shop.admin.themes]
    PARTNER_SCOPES = %w[https://api.shopify.com/auth/partners.app.cli.access]

    property! :ctx
    property :store, default: ShopifyCli::DB.new
    property :state_token, accepts: String, default: SecureRandom.hex(30)
    property :code_verifier, accepts: String, default: SecureRandom.hex(30)

    attr_accessor :response_query

    def authenticate
      return if refresh_exchange_token
      return if refresh_access_token
      initiate_authentication
      request_access_token(code: receive_access_code)
      request_exchange_tokens
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
        server.mount("/", OAuth::Servlet, self, state_token)
        server
      end
    end

    private

    def initiate_authentication
      @server_thread = Thread.new { server.start }
      params = {
        client_id: client_id,
        scope: scopes(SHOPIFY_SCOPES + PARTNER_SCOPES),
        redirect_uri: REDIRECT_HOST,
        state: state_token,
        response_type: :code,
      }
      params.merge!(challange_params)
      uri = URI.parse("#{auth_url}/authorize")
      uri.query = URI.encode_www_form(params)
      output_authentication_info(uri)
    end

    def output_authentication_info(uri)
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

    def request_access_token(code:)
      resp = post_token_request(
        grant_type: :authorization_code,
        code: code,
        redirect_uri: REDIRECT_HOST,
        client_id: client_id,
        code_verifier: code_verifier,
      )
      store.set(
        "identity_access_token".to_sym => resp["access_token"],
        "identity_refresh_token".to_sym => resp["refresh_token"],
      )
    end

    def refresh_access_token
      return false if !store.exists?("identity_access_token".to_sym) ||
        !store.exists?("identity_refresh_token".to_sym)
      refresh_token
      request_exchange_tokens
      true
    rescue
      store.del("identity_access_token".to_sym, "identity_refresh_token".to_sym)
      false
    end

    def refresh_token
      resp = post_token_request(
        grant_type: :refresh_token,
        access_token: store.get("identity_access_token".to_sym),
        refresh_token: store.get("identity_refresh_token".to_sym),
        client_id: client_id,
      )
      store.set(
        "identity_access_token".to_sym => resp["access_token"],
        "identity_refresh_token".to_sym => resp["refresh_token"],
      )
    end

    def refresh_exchange_token
      return false if !store.exists?("partners_exchange_token".to_sym) ||
      !store.exists?("shopify_exchange_token".to_sym)
      request_exchange_tokens
      true
    rescue
      store.del("partners_exchange_token".to_sym)
      store.del("shopify_exchange_token".to_sym)
      false
    end

    def request_exchange_tokens
      request_exchange_token("partners", partners_id, PARTNER_SCOPES)
      request_exchange_token("shopify", shopify_id, SHOPIFY_SCOPES)
    end

    def request_exchange_token(name, audience, additional_scopes)
      resp = post_token_request(
        grant_type: "urn:ietf:params:oauth:grant-type:token-exchange",
        requested_token_type: "urn:ietf:params:oauth:token-type:access_token",
        subject_token_type: "urn:ietf:params:oauth:token-type:access_token",
        client_id: client_id,
        audience: audience,
        scope: scopes(additional_scopes),
        subject_token: store.get("identity_access_token".to_sym),
      )
      store.set("#{name}_exchange_token".to_sym => resp["access_token"])
    end

    def post_token_request(params)
      post_request("/token", params)
    end

    def post_request(endpoint, params)
      uri = URI.parse("#{auth_url}#{endpoint}")
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

    def auth_url
      return "https://accounts.shopify.com/oauth" if ENV[LOCAL_DEBUG].nil?
      "https://identity.myshopify.io/oauth"
    end

    def partners_id
      return "271e16d403dfa18082ffb3d197bd2b5f4479c3fc32736d69296829cbb28d41a6" if ENV[LOCAL_DEBUG].nil?
      "df89d73339ac3c6c5f0a98d9ca93260763e384d51d6038da129889c308973978"
    end

    def shopify_id
      return "7ee65a63608843c577db8b23c4d7316ea0a01bd2f7594f8a9c06ea668c1b775c" if ENV[LOCAL_DEBUG].nil?
      # 'don't have a DEBUG one yet'
    end

    def scopes(additional_scopes = [])
      (["openid"] + additional_scopes).tap do |result|
        result << "employee" if ShopifyCli::Shopifolk.acting_as_shopify_organization?
      end.join(" ")
    end

    def client_id
      return "fbdb2649-e327-4907-8f67-908d24cfd7e3" if ENV[LOCAL_DEBUG].nil?

      ctx.abort(ctx.message("core.oauth.error.local_identity_not_running")) unless local_identity_running?

      # Fetch the client ID from the local Identity Dynamic Registration endpoint
      response = post_request("/client", {
        name: "shopify-cli-development",
        public_type: "native",
      })

      response["client_id"]
    end

    def local_identity_running?
      Net::HTTP.start("identity.myshopify.io", 443, use_ssl: true, open_timeout: 1, read_timeout: 10) do |http|
        req = Net::HTTP::Get.new(URI.join("https://identity.myshopify.io", "/services/ping"))
        http.request(req).is_a?(Net::HTTPSuccess)
      end
    rescue Timeout::Error, Errno::EHOSTUNREACH, Errno::EHOSTDOWN, Errno::EADDRNOTAVAIL, Errno::ECONNREFUSED
      false
    end
  end
end
