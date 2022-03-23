# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/dev_server/remote_watcher/json_files_update_job"

module ShopifyCLI
  module Theme
    module DevServer
      class RemoteWatcher
        class JsonFilesUpdateJobTest < Minitest::Test
          def setup
            super

            interval = 2
            @job = JsonFilesUpdateJob.new(theme, syncer, interval)
          end

          def test_perform
            file1 = mock
            file2 = mock
            file3 = mock
            syncer.stubs(pending_updates: [file2])
            theme.stubs(json_files: [file1, file2, file3])

            syncer.expects(:fetch_checksums!)
            syncer.expects(:enqueue_get).with([file1, file3])

            @job.perform!
          end

          def test_recurring
            assert(@job.recurring?)
            assert_equal(2, @job.interval)
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
end
