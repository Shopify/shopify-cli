# frozen_string_literal: true

require_relative "bulk_job"
require "shopify_cli/thread_pool"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class Bulk
        MAX_BULK_BYTESIZE = 10_485_760 # 10MB
        MAX_BULK_FILES = 20 # files
        QUEUE_TIMEOUT = 0.2 # 200ms

        attr_accessor :admin_api

        def initialize(ctx, admin_api, pool_size: 20)
          @ctx = ctx
          @admin_api = admin_api
          @latest_enqueued_at = now

          @thread_pool = ShopifyCLI::ThreadPool.new(pool_size: pool_size)

          pool_size.times do
            @thread_pool.schedule(
              BulkJob.new(ctx, self)
            )
          end

          @put_requests = []
          @mut = Mutex.new
        end

        def enqueue(put_request)
          @mut.synchronize do
            @latest_enqueued_at = now
            @put_requests << put_request
          end
        end

        def shutdown
          sleep(0.2) until @put_requests.empty?
          @thread_pool.shutdown
        end

        def consume_put_requests
          
          to_batch = []
          to_batch_size_bytes = 0
          @mut.synchronize do
            # sort requests to perform less retries at the `bulk_job`` level
            @put_requests.sort_by! { |r| r.liquid? ? 0 : 1 }

            is_ready = false
            until is_ready || @put_requests.empty?
              request = @put_requests.first
              if to_batch.empty? && request.size > MAX_BULK_BYTESIZE
                is_ready = true
                to_batch << request
                @put_requests.shift
              elsif to_batch.size + 1 > MAX_BULK_FILES || to_batch_size_bytes + request.size > MAX_BULK_BYTESIZE
                is_ready = true
              else
                to_batch << request
                to_batch_size_bytes += request.size
                @put_requests.shift
              end
            end
          end

          to_batch
        end

        def ready?
          queue_timeout? || bulk_size >= MAX_BULK_FILES || bulk_bytesize >= MAX_BULK_BYTESIZE
        end

        def bulk_bytesize
          @put_requests.map(&:size).reduce(:+).to_i
        end

        private

        def bulk_size
          @put_requests.size
        end

        def queue_timeout?
          return false if bulk_size.zero?
          elapsed_time = now - @latest_enqueued_at
          elapsed_time > QUEUE_TIMEOUT
        end

        def now
          Time.now.to_f
        end
      end
    end
  end
end
