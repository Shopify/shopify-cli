require 'shopify_cli'

module ShopifyCli
  class API
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
        body: JSON.dump(query: load_query(query_name).tr("\n", ""), variables: variables),
        url: url,
      )
      ctx.debug(resp)
      resp
    rescue API::APIRequestServerError, API::APIRequestUnexpectedError => e
      ctx.puts(ctx.message('core.api.error.internal_server_error'))
      ctx.debug(ctx.message('core.api.error.internal_server_error_debug', e.message))
    end

    def request(url:, body: nil, headers: {}, method: "POST")
      CLI::Kit::Util.begin do
        uri = URI.parse(url)
        unless uri.is_a?(URI::HTTP)
          ctx.abort(ctx.message('core.api.error.invalid_url', url))
        end

        # we delay this require so as to avoid a performance hit on starting the CLI
        require 'shopify-cli/http_request'
        headers = default_headers.merge(headers)
        response = if method == "POST"
          HttpRequest.post(uri, body, headers)
        elsif method == "GET"
          HttpRequest.get(uri, body, headers)
        end

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

    protected

    def load_query(name)
      project_type = ShopifyCli::Project.current_project_type
      project_file_path = File.join(
        ShopifyCli::ROOT, 'lib', 'project_types', project_type.to_s, 'graphql', "#{name}.graphql"
      )
      if !project_type.nil? && File.exist?(project_file_path)
        File.read(project_file_path)
      else
        File.read(File.join(ShopifyCli::ROOT, 'lib', 'graphql', "#{name}.graphql"))
      end
    end

    private

    def current_sha
      @current_sha ||= Git.sha(dir: ShopifyCli::ROOT)
    end

    def default_headers
      {
        'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} #{current_sha} | #{ctx.uname}",
      }.merge(auth_headers(token))
    end

    def auth_headers(token)
      raise NotImplementedError if auth_header.nil?
      { auth_header => token }
    end
  end
end
