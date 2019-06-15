require 'shopify_cli'

module ShopifyCli
  module Helpers
    class API
      include SmartProperties

      API_VERSION = '2019-04'

      property :ctx, required: true, accepts: ShopifyCli::Context
      property :token, required: true

      class APIRequestError < StandardError; end
      class APIRequestClientError < APIRequestError; end
      class APIRequestUnauthorizedError < APIRequestClientError; end
      class APIRequestUnexpectedError < APIRequestError; end
      class APIRequestRetriableError < APIRequestError; end
      class APIRequestServerError < APIRequestRetriableError; end
      class APIRequestThrottledError < APIRequestRetriableError; end

      def graphql_url
        "https://#{ctx.project.env.shop}/admin/api/#{API_VERSION}/graphql.json"
      end

      def mutation(mutation)
        query = mutation_body(mutation)
        _, resp = post(
          graphql_url, query
        )
        @ctx.debug(resp)
        resp
      end

      def post(url, body = "{}")
        request(url: url) do |uri|
          req = Net::HTTP::Post.new(uri.request_uri)
          req.body = body
          req
        end
      end

      def request(url: raise)
        CLI::Kit::Util.begin do
          raise 'Invalid Usage: Block must return a request' unless block_given?

          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = yield(uri)
          headers.each { |header, value| request[header] = value }
          request["X-Shopify-Access-Token"] = token
          response = http.request(request)

          case response.code.to_i
          when 200..399
            [response.code.to_i, JSON.parse(response.body)]
          when 401
            raise APIRequestUnauthorizedError, "#{response.code}\n#{response.body}"
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

      def mutation_body(mutation, variables: {})
        query = <<~MUTATION
          mutation {
            #{mutation}
          }
        MUTATION
        JSON.dump(
          query: query.tr("\n", ""),
          variables: variables,
        )
      end

      def gid_to_id(gid)
        gid.split('/').last
      end

      def pause
        sleep(1)
      end

      private

      def headers
        headers = {
          'Content-Type' => 'application/json',
          'User-Agent' => 'Shopify App CLI',
        }
        headers
      end
    end
  end
end
