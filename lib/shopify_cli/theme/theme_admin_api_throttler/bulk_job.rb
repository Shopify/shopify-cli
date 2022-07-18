# frozen_string_literal: true

require "shopify_cli/thread_pool/job"
require_relative "request_parser"
require_relative "response_parser"
require_relative "errors"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class BulkJob < ShopifyCLI::ThreadPool::Job
        JOB_TIMEOUT = 0.2 # 200ms
        MAX_RETRIES = 10

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
          put_requests, bulk_size = bulk.consume_put_requests
          return if put_requests.empty?

          @ctx.debug("[BulkJob] size: #{put_requests.size}, bytesize: #{bulk_size}")
          bulk_status, bulk_body, response = rest_request(put_requests)

          if bulk_status == 207
            responses(bulk_body).each_with_index do |tuple, index|
              status, body = tuple
              put_request = put_requests[index]
              if status == 200 || put_request.retries >= MAX_RETRIES
                @block_mutex.synchronize do
                  if status == 200
                    @ctx.debug("[BulkJob] asset saved: #{put_request.key}")
                    put_request.block.call(status, body, response)
                  else
                    @ctx.debug("[BulkJob] asset continuing with error: #{put_request.key}")
                    err = AssetUploadError.new(body, response: { body: body })
                    put_request.block.call(status, {}, err)
                  end
                end
              else
                @ctx.debug("[BulkJob] asset error: #{put_request.key}")
                @block_mutex.synchronize do
                  put_request.retries += 1
                  bulk.enqueue(put_request)
                end
              end
            end
          else
            @ctx.puts(@ctx.message("theme.stable_flag_suggestion"))
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
