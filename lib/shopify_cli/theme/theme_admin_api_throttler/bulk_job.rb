# frozen_string_literal: true

require "shopify_cli/thread_pool/job"
require_relative "request_parser"
require_relative "response_parser"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkJob < ShopifyCLI::ThreadPool::Job
        JOB_TIMEOUT = 0.2 # 200ms

        attr_reader :bulk

        def initialize(ctx, bulk)
          super(JOB_TIMEOUT)
          @ctx = ctx
          @bulk = bulk

          # Mutex used to coordinate changes performed by the bulk item block
          @block_mutex = Mutex.new
        end

        def perform!
          return unless bulk.ready?
          put_requests = bulk.consume_put_requests

          bulk_status, bulk_body, response = rest_request(put_requests)

          if bulk_status == 207
            responses(bulk_body).each_with_index do |tuple, index|
              status, body = tuple
              put_request = put_requests[index]
              if status == 200 || put_request.retries > 5
                @ctx.debug("[BulkJob] asset saved: #{put_request}")
                @block_mutex.synchronize do
                  put_request.block.call(status, body, response)
                end
              else
                @ctx.debug("[BulkJob] asset error: #{put_request}")
                @block_mutex.synchronize do
                  put_request.retries += 1
                  bulk.enqueue(put_request)
                end
              end
            end
          else
            # ignore
            @ctx.puts("Suggest --stable flag")
          end
        end

        private

        def rest_request(put_requests)
          request = RequestParser.new(put_requests).parse
          bulk.admin_api.rest_request(**request)
        end

        def responses(response_body)
          ResponseParser.new(response_body).parse
        end
      end
    end
  end
end
