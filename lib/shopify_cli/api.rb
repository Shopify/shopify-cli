require "shopify_cli"
require "securerandom"

module ShopifyCLI
  class API
    include SmartProperties

    property! :ctx, accepts: ShopifyCLI::Context
    property! :token, accepts: String
    property :auth_header, accepts: String
    property! :url, accepts: String

    class APIRequestError < StandardError
      attr_reader :response

      def initialize(message = nil, response: nil)
        super(message)
        @response = response
      end
    end

    class APIRequestNotFoundError < APIRequestError; end
    class APIRequestClientError < APIRequestError; end
    class APIRequestUnauthorizedError < APIRequestClientError; end
    class APIRequestForbiddenError < APIRequestClientError; end
    class APIRequestUnexpectedError < APIRequestError; end
    class APIRequestRetriableError < APIRequestError; end
    class APIRequestTimeoutError < APIRequestRetriableError; end
    class APIRequestServerError < APIRequestRetriableError; end
    class APIRequestThrottledError < APIRequestRetriableError; end

    def self.gid_to_id(gid)
      gid.split("/").last
    end

    def query(query_name, variables: {})
      _, resp = request(
        body: JSON.dump(query: load_query(query_name).tr("\n", ""), variables: variables),
        url: url,
      )
      ctx.debug(resp)
      resp
    rescue API::APIRequestServerError, API::APIRequestUnexpectedError => e
      ctx.puts(ctx.message("core.api.error.internal_server_error"))
      ctx.debug(ctx.message("core.api.error.internal_server_error_debug", e.message))
    end

    def request(url:, body: nil, headers: {}, method: "POST")
      CLI::Kit::Util.begin do
        uri = URI.parse(url)
        unless uri.is_a?(URI::HTTP)
          ctx.abort(ctx.message("core.api.error.invalid_url", url))
        end

        # we delay this require so as to avoid a performance hit on starting the CLI
        require "shopify_cli/http_request"
        headers = default_headers.merge(headers)
        ctx.debug("#{method} #{uri} with X-Request-Id: #{headers["X-Request-Id"]}")
        response = if method == "POST"
          HttpRequest.post(uri, body, headers)
        elsif method == "PUT"
          HttpRequest.put(uri, body, headers)
        elsif method == "GET"
          HttpRequest.get(uri, body, headers)
        elsif method == "DELETE"
          HttpRequest.delete(uri, body, headers)
        end
        case response.code.to_i
        when 200..399
          [response.code.to_i, JSON.parse(response.body), response]
        when 401
          raise APIRequestUnauthorizedError.new("#{response.code}\n#{response.body}", response: response)
        when 403
          raise APIRequestForbiddenError.new("#{response.code}\n#{response.body}", response: response)
        when 404
          raise APIRequestNotFoundError.new("#{response.code}\n#{response.body}", response: response)
        when 429
          raise APIRequestThrottledError.new("#{response.code}\n#{response.body}", response: response)
        when 400..499
          raise APIRequestClientError.new("#{response.code}\n#{response.body}", response: response)
        when 500..599
          raise APIRequestServerError.new("#{response.code}\n#{response.body}", response: response)
        else
          raise APIRequestUnexpectedError.new("#{response.code}\n#{response.body}", response: response)
        end
      rescue Errno::ETIMEDOUT, Timeout::Error
        ctx.debug("timeout in #{method} #{uri} with X-Request-Id: #{headers["X-Request-Id"]}")
        raise APIRequestTimeoutError.new("Timeout")
      end.retry_after(APIRequestRetriableError, retries: 3) do |e|
        sleep(1) if e.is_a?(APIRequestThrottledError)
      end
    end

    protected

    def load_query(name)
      project_type = ShopifyCLI::Project.current_project_type
      project_file_path = File.join(
        ShopifyCLI::ROOT, "lib", "project_types", project_type.to_s, "graphql", "#{name}.graphql"
      )
      if !project_type.nil? && File.exist?(project_file_path)
        File.read(project_file_path)
      else
        File.read(File.join(ShopifyCLI::ROOT, "lib", "graphql", "#{name}.graphql"))
      end
    end

    private

    def default_headers
      sha = ShopifyCLI.sha
      user_agent = "Shopify CLI; v=#{ShopifyCLI::VERSION}"
      sec_ch_ua = user_agent
      sec_ch_ua += " sha=#{sha}" unless sha.nil?

      {
        "User-Agent" => user_agent,
        "Sec-CH-UA" => sec_ch_ua,
        "Sec-CH-UA-PLATFORM" => ctx.os.to_s,
        "X-Request-Id" => SecureRandom.uuid,
      }.tap do |headers|
        headers["X-Shopify-Cli-Employee"] = "1" if Shopifolk.acting_as_shopify_organization?
      end.merge(auth_headers(token))
    end

    def auth_headers(token)
      raise NotImplementedError if auth_header.nil?
      { auth_header => token }
    end
  end
end
