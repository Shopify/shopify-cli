# frozen_string_literal: true
require_relative "syncer/extension_serve_job"
require "shopify_cli/thread_pool"

module ShopifyCLI
  module Theme
    module Extension
      class Syncer
        attr_accessor :pending_updates, :latest_sync

        def initialize(ctx, extension:, project:, specification_handler:)
          @ctx = ctx
          @extension = extension
          @project = project
          @specification_handler = specification_handler

          @pool = ThreadPool.new(pool_size: 1)
          @pending_updates = extension.extension_files
          @update_mutex = Mutex.new
          @latest_sync = Time.now - ExtensionServeJob::PUSH_INTERVAL
        end

        def enqueue_files(files)
          @update_mutex.synchronize do
            files.each { |f| @pending_updates << f unless @pending_updates.include?(f) }
          end
        end

        def start
          @pool.schedule(job)
        end

        def shutdown
          @pool.shutdown
        end

        private

        def job
          ExtensionServeJob.new(
            @ctx,
            syncer: self,
            extension: @extension,
            project: @project,
            specification_handler: @specification_handler
          )
        end
      end
    end
  end
end
