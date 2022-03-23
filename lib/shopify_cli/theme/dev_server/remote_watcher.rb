# frozen_string_literal: true

require "shopify_cli/thread_pool"

require_relative "remote_watcher/json_files_update_job"

module ShopifyCLI
  module Theme
    module DevServer
      class RemoteWatcher
        class << self
          def to(theme:, syncer:, interval:)
            new(theme, syncer, interval)
          end
        end

        def start
          return unless activated?
          thread_pool.schedule(recurring_job)
        end

        def stop
          return unless activated?
          thread_pool.shutdown
        end

        private

        def initialize(theme, syncer, interval)
          @theme = theme
          @syncer = syncer
          @interval = interval
        end

        def thread_pool
          @thread_pool ||= ShopifyCLI::ThreadPool.new(pool_size: 1)
        end

        def activated?
          @interval > 0
        end

        def recurring_job
          JsonFilesUpdateJob.new(@theme, @syncer, @interval)
        end
      end
    end
  end
end
