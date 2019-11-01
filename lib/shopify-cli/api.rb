require 'shopify_cli'
require 'net/http'

module ShopifyCli
  class API
    include Helpers::OS
    include SmartProperties

    property! :ctx, accepts: ShopifyCli::Context
    property! :token, accepts: String
    property :auth_header, accepts: String
    property! :url, accepts: String

    class APIRequestError < StandardError; end
    class APIRequestNotFoundError < APIRequestError; end
    class APIRequestClientError < APIRequestError; end
    class APIRequestUnauthorizedError < APIRequestClientError; end
    class APIRequestUnexpectedError < APIRequestError; end
    class APIRequestRetriableError < APIRequestError; end
    class APIRequestServerError < APIRequestRetriableError; end
    class APIRequestThrottledError < APIRequestRetriableError; end

    def self.gid_to_id(gid)
      gid.split('/').last
    end

    def query(query_name, variables: {})
      _, resp = request(
        load_query(query_name),
        variables: variables,
        headers: default_headers,
        graphql_url: url,
      )
      ctx.debug(resp)
      resp
    end

    private

    def load_query(name)
      File.read(File.join(ShopifyCli::ROOT, "lib/graphql/#{name}.graphql"))
    end

    def request(body, graphql_url:, variables: {}, headers: {})
      CLI::Kit::Util.begin do
        uri = URI.parse(graphql_url)
        http = ::Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true

        req = ::Net::HTTP::Post.new(uri.request_uri)
        req.body = JSON.dump(query: body.tr("\n", ""), variables: variables)
        req['Content-Type'] = 'application/json'
        headers.each { |header, value| req[header] = value }
        response = http.request(req)

        case response.code.to_i
        when 200..399
          [response.code.to_i, JSON.parse(response.body)]
        when 401
          raise APIRequestUnauthorizedError, "#{response.code}\n#{response.body}"
        when 404
          raise APIRequestNotFoundError, "#{response.code}\n#{response.body}"
        when 429
          raise APIRequestThrottledError, "#{response.code}\n#{response.body}"
        when 400..499
          raise APIRequestClientError, "#{response.code}\n#{response.body}"
        when 500..599
          raise APIRequestServerError, "#{response.code}\n#{response.body}"
        else
          raise APIRequestUnexpectedError, "#{response.code}\n#{response.body}"
        end
      end.retry_after(APIRequestRetriableError, retries: 3) do |e|
        sleep(1) if e.is_a?(APIRequestThrottledError)
      end
    end

    def current_sha
      @current_sha ||= Helpers::Git.sha(dir: ShopifyCli::ROOT)
    end

    def default_headers
      {
        'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} #{current_sha} | #{uname(flag: 'v')}",
      }.merge(auth_headers(token))
    end

    def auth_headers(token)
      raise NotImplementedError if auth_header.nil?
      { auth_header => token }
    end
  end
end
