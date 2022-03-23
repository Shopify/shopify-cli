# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    module DevServer
      class RemoteWatcherTest < Minitest::Test
        def test_start_when_it_is_activated
          thread_pool = mock
          job = mock

          watcher = RemoteWatcher.to(theme: theme, syncer: syncer, interval: 1)
          watcher.stubs(:thread_pool).returns(thread_pool)
          watcher.stubs(:recurring_job).returns(job)

          thread_pool.expects(:schedule).with(job)

          watcher.start
        end

        def test_start_when_it_is_not_activated
          thread_pool = mock

          watcher = RemoteWatcher.to(theme: theme, syncer: syncer, interval: 0)
          watcher.stubs(:thread_pool).returns(thread_pool)

          thread_pool.expects(:schedule).never

          watcher.start
        end

        def test_stop_when_it_is_activated
          thread_pool = mock

          watcher = RemoteWatcher.to(theme: theme, syncer: syncer, interval: 1)
          watcher.stubs(:thread_pool).returns(thread_pool)

          thread_pool.expects(:shutdown)

          watcher.stop
        end

        def test_stop_when_it_is_not_activated
          thread_pool = mock

          watcher = RemoteWatcher.to(theme: theme, syncer: syncer, interval: 0)
          watcher.stubs(:thread_pool).returns(thread_pool)

          thread_pool.expects(:shutdown).never

          watcher.stop
        end

        private

        def theme
          @theme ||= mock
        end

        def syncer
          @syncer ||= mock
        end
      end
    end
  end
end
