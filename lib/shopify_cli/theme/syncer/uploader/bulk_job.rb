# frozen_string_literal: true

require "shopify_cli/thread_pool/job"

require_relative "bulk_request"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class BulkJob < ShopifyCLI::ThreadPool::Job
          INTERVAL = 0.2 # 200ms
          MAX_RETRIES = 10

          attr_reader :ctx, :bulk, :admin_api

          def initialize(ctx, bulk)
            super(INTERVAL)

            @ctx = ctx
            @bulk = bulk
            @admin_api = bulk.admin_api

            # Mutex used to coordinate changes in the bulk items
            @bulk_item_mutex = Mutex.new

            # Mutex used to coordinate changes in the bulk items
            @bulk_item_mutex = Mutex.new
          end

          def perform!
            bulk.wait_for_backoff!

            # Fetch bulk items
            bulk_items, bulk_size = bulk.consume_bulk_items
            return if bulk_items.empty?

            # Perform bulk request
            log("job request: size=#{bulk_items.size}, bytesize=#{bulk_size}")
            bulk_status, bulk_body, response = rest_request(bulk_items)
            bulk.backoff_if_near_limit!(response)
            log("job response: http_status=#{bulk_status}")

            # Abort execution when a fatal error happens
            return stable_flag_suggestion! if bulk_status != 207

            # Handle item reponses
            responses = parse_responses(bulk_body)
            responses
              .each_with_index do |tuple, index|
                status, body = tuple
                bulk_item = bulk_items[index]
                handle_item_response(bulk_item, status, body, response)
              end
          ensure
            bulk.clean_in_progress_items(bulk_items)
          end

          private

          def handle_item_response(bulk_item, status, body, response)
            if status == 200
              return handle_success(bulk_item, status, body, response)
            end

            if bulk_item.retries < MAX_RETRIES
              return handle_retry(bulk_item, status, body, response)
            end

            handle_error(bulk_item, status, body)
          end

          def handle_success(bulk_item, status, body, response)
            log("bulk item success (item=#{bulk_item.key})")

            @bulk_item_mutex.synchronize do
              bulk_item.block.call(status, body, response)
            end
          end

          def handle_retry(bulk_item, status, _body, _response)
            key = bulk_item.key
            retries = bulk_item.retries

            log("bulk item error (item=#{key}, status=#{status}, retries=#{retries})")

            @bulk_item_mutex.synchronize do
              bulk_item.retries += 1
              bulk.enqueue(bulk_item)
            end
          end

          def handle_error(bulk_item, status, body)
            log("bulk item fatal error (item=#{bulk_item.key}, status=#{status})")

            @bulk_item_mutex.synchronize do
              bulk_item.block.call(status, body, error_response(body))
            end
          end

          def stable_flag_suggestion!
            ctx.abort(ctx.message("theme.stable_flag_suggestion"))
          end

          def rest_request(bulk_items)
            theme = bulk.theme
            args = BulkRequest.new(theme, bulk_items).to_h

            measure("bulk rest_request") { admin_api.rest_request(**args) }
          end

          def measure(subject)
            return yield unless ctx.debug?

            start_time = Time.now
            result = yield
            time_elapsed = (Time.now - start_time) * 1000

            log("#{subject} time: #{time_elapsed}ms")

            result
          end

          def parse_responses(body)
            body["results"]&.map { |r| [r["code"], r["body"]] } || []
          end

          def error_response(body)
            ShopifyCLI::API::APIRequestError.new(body, response: { body: body })
          end

          def log(message)
            ctx.debug("[BulkJob ##{object_id}] #{message}")
          end
        end
      end
    end
  end
end
