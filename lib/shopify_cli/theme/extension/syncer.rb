# frozen_string_literal: true
require_relative "syncer/extension_serve_job"

module ShopifyCLI
  module Theme
    module Extension
      class Syncer
        attr_accessor :pending_updates, :latest_sync

        def initialize(ctx, extension:)
          @ctx = ctx
          @extension = extension

          @pool = ThreadPool.new(pool_size: 1)
          @pending_updates = []
          @update_mutex = Mutex.new
          @latest_sync = Time.now
        end

        def enqueue_files(files)
          @update_mutex.synchronize do
            files.each { |f| @pending_updates << f }
          end
        end

        def start
          @pool.schedule(ExtensionServeJob.new(@ctx, syncer: self, extension: @extension))
        end

        def shutdown
          @pool.shutdown
        end
      end
    end
  end
end
