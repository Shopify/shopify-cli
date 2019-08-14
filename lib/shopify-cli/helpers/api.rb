require 'shopify_cli'
require 'net/http'

module ShopifyCli
  module Helpers
    class API
      include OS
      include SmartProperties

      property! :ctx, accepts: ShopifyCli::Context
      property! :token
      property :url, default: -> { graphql_url }

      class APIRequestError < StandardError; end
      class APIRequestNotFoundError < APIRequestError; end
      class APIRequestClientError < APIRequestError; end
      class APIRequestUnauthorizedError < APIRequestClientError; end
      class APIRequestUnexpectedError < APIRequestError; end
      class APIRequestRetriableError < APIRequestError; end
      class APIRequestServerError < APIRequestRetriableError; end
      class APIRequestThrottledError < APIRequestRetriableError; end

      def mutation(mutation, variables: {})
        _, resp = request("mutation { #{mutation} }", variables: variables)
        @ctx.debug(resp)
        resp
      end

      def query(body, variables: {})
        _, resp = request(body, variables: variables)
        @ctx.debug(resp)
        resp
      end

      def gid_to_id(gid)
        gid.split('/').last
      end

      private

      def request(body, variables: {}, graphql_url: url)
        CLI::Kit::Util.begin do
          uri = URI.parse(graphql_url)
          http = ::Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          req = ::Net::HTTP::Post.new(uri.request_uri)
          req.body = JSON.dump(query: body.tr("\n", ""), variables: variables)
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
          pause if e.is_a?(APIRequestThrottledError)
        end
      end

      def graphql_url
        "https://#{Project.current.env.shop}/admin/api/#{latest_api_version}/graphql.json"
      end

      def latest_api_version
        @latest_api_version ||= fetch_latest_api_version
      end

      def fetch_latest_api_version
        version_url = "https://#{Project.current.env.shop}/admin/api/unstable/graphql.json"
        query = '{ publicApiVersions() { handle displayName } }'
        _, response = request(query, graphql_url: version_url)
        ctx.debug(response)
        versions = response['data']['publicApiVersions']
        latest = versions.find { |version| version['displayName'].include?('Latest') }
        latest['handle']
      end

      def pause
        sleep(1)
      end

      def current_sha
        output, status = @ctx.capture2e('git', 'rev-parse', 'HEAD', chdir: ShopifyCli::ROOT)
        status.success? ? output.strip : 'SHA unavailable'
      end

      def headers
        {
          'Content-Type' => 'application/json',
          'User-Agent' => "Shopify App CLI #{ShopifyCli::VERSION} #{current_sha} | #{uname(flag: 'v')}",
          'X-Shopify-Access-Token' => token,
          'Authorization' => "Bearer #{token}",
        }
      end
    end
  end
end
