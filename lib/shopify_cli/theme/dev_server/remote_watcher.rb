# frozen_string_literal: true

require "shopify_cli/thread_pool"

require_relative "remote_watcher/json_files_update_job"

module ShopifyCLI
  module Theme
    class DevServer
      class RemoteWatcher
        SYNC_INTERVAL = 3 # seconds

        class << self
          def to(theme:, syncer:)
            new(theme, syncer)
          end
        end

        def start
          thread_pool.schedule(recurring_job)
        end

        def stop
          thread_pool.shutdown
        end

        private

        def initialize(theme, syncer)
          @theme = theme
          @syncer = syncer
        end

        def thread_pool
          @thread_pool ||= ShopifyCLI::ThreadPool.new(pool_size: 1)
        end

        def recurring_job
          JsonFilesUpdateJob.new(@theme, @syncer, SYNC_INTERVAL)
        end
      end
    end
  end
end
