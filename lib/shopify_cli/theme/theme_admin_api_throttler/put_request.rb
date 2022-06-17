# frozen_string_literal: true

require "shopify_cli/thread_pool/job"
require_relative "request_parser"
require_relative "response_parser"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class PutRequest
        attr_reader :method, :body, :path, :block
        attr_accessor :retries

        def initialize(path, body, &block)
          @method = "PUT"
          @path = path
          @body = body
          @block = block
          @retries = 0
        end

        def to_h
          {
            method: method,
            path: path,
            body: body,
          }
        end

        def to_s
          "#{key}, retries: #{retries}"
        end

        def liquid?
          key.end_with?(".liquid")
        end

        def key
          JSON.parse(body)["asset"]["key"]
        end

        def bulk_path
          path.gsub(/.json$/, "/bulk.json")
        end

        def size
          @size ||= body.bytesize
        end
      end
    end
  end
end
