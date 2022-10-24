# frozen_string_literal: true

require "shopify_cli/thread_pool"
require "shopify_cli/theme/backoff_helper"

require_relative "bulk_job"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class Bulk
          include ShopifyCLI::Theme::BackoffHelper

          MAX_BULK_BYTESIZE = 102_400   # 100KB
          MAX_BULK_FILES = 10           # 10 files
          SHUTDOWN_TIMEOUT = 20         # 20 seconds
          SHUTDOWN_RETRY_INTERVAL = 0.2 # 200 milliseconds

          attr_reader :ctx, :theme, :admin_api

          def initialize(ctx, theme, admin_api, pool_size: 15)
            @ctx = ctx
            @theme = theme
            @admin_api = admin_api
            @pending_items = []
            @in_progress_items = []

            # Mutex used to coordinate changes in the `@pending_items` shared
            # accross the `@thread_pool` threads
            @pending_items_mutex = Mutex.new

            # Mutex used to coordinate changes in the `@in_progress_items`
            # shared accross the `@thread_pool` threads
            @in_progress_items_mutex = Mutex.new

            # Initialize thread pool and the jobs
            @thread_pool = initialize_thread_pool!(pool_size)

            # Initialize backoff helper on main thread to pause all jobs when
            # requests are reaching API rate limits
            initialize_backoff_helper!(margin: pool_size, backoff_delay: 5)
          end

          def enqueue(bulk_item)
            @pending_items_mutex.synchronize { @pending_items << bulk_item }
          end

          def shutdown
            wait_bulk_items
            @thread_pool.shutdown
          end

          def consume_bulk_items
            items = []
            items_bytesize = 0

            @pending_items_mutex.synchronize do
              has_enough_items = false
              has_enough_bytesize = false

              until has_enough_items || has_enough_bytesize || @pending_items.empty?
                bulk_item = @pending_items.first

                has_enough_items = items.size + 1 > MAX_BULK_FILES
                has_enough_bytesize = items_bytesize + bulk_item.size > MAX_BULK_BYTESIZE

                break if items.any? && (has_enough_items || has_enough_bytesize)

                items << bulk_item
                items_bytesize += bulk_item.size

                @pending_items.shift
              end
            end

            @in_progress_items_mutex.synchronize do
              @in_progress_items += items
            end

            [items, items_bytesize]
          end

          def clean_in_progress_items(items)
            @in_progress_items_mutex.synchronize do
              @in_progress_items -= items
            end
          end

          def remaining_items
            @pending_items + @in_progress_items
          end

          private

          def wait_bulk_items
            start_time = Time.now

            wait(SHUTDOWN_RETRY_INTERVAL) while remaining_items? && start_time - Time.now < SHUTDOWN_TIMEOUT

            files = remaining_items.map { |item| "- #{item.key}" }.join("\n")

            log("shutdown, remaining_items=#{remaining_items.size}\n#{files}")
          end

          def remaining_items?
            !@pending_items.empty? || !@in_progress_items.empty?
          end

          def initialize_thread_pool!(pool_size)
            ShopifyCLI::ThreadPool
              .new(pool_size: pool_size)
              .tap do |thread_pool|
                pool_size.times { thread_pool.schedule(spawn_job) }
              end
          end

          def spawn_job
            BulkJob.new(ctx, self)
          end

          def log(message)
            ctx.debug("[Bulk] #{message}")
          end

          def wait(seconds)
            sleep(seconds)
          end
        end
      end
    end
  end
end
