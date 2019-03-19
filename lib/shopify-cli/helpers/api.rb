# frozen_string_literal: true
require 'shopify_cli'
require 'json'
require 'net/http'
require 'uri'

module ShopifyCli
  module Helpers
    class API
      autoload :Partners,  'shopify-cli/helpers/api/partners'

      class APIRequestError < StandardError; end
      class APIRequestClientError < APIRequestError; end
      class APIRequestUnauthorizedError < APIRequestClientError; end
      class APIRequestUnexpectedError < APIRequestError; end
      class APIRequestRetriableError < APIRequestError; end
      class APIRequestServerError < APIRequestRetriableError; end
      class APIRequestThrottledError < APIRequestRetriableError; end

      def initialize(ctx)
        @ctx = ctx
      end

      def get(url, authorization: nil)
        request(url: url, authorization: authorization) do |uri|
          Net::HTTP::Get.new(uri.request_uri)
        end
      end

      def post(url, body = "{}", authorization: nil)
        request(url: url, authorization: authorization) do |uri|
          req = Net::HTTP::Post.new(uri.request_uri)
          req.body = body
          req
        end
      end

      def request(url: raise, authorization: nil)
        CLI::Kit::Util.begin do
          raise 'Invalid Usage: Block must return a request' unless block_given?

          uri = URI.parse(url)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          request = yield(uri)
          headers.each { |header, value| request[header] = value }
          request["Authorization"] = "Bearer #{authorization}" if authorization
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

      def headers
        headers = {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'User-Agent' => 'Shopify Dev',
        }
        headers["Authorization"] = "Bearer #{@access_token}" if @access_token
        headers
      end

      def pause
        sleep(1)
      end

      def log(*args)
        @ctx.log(*args)
      end
    end
  end
end
