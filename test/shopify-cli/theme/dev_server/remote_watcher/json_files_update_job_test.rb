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
            file4 = mock
            file5 = mock

            syncer.stubs(pending_updates: [file2])
            syncer.stubs(:broken_file?).returns(false)
            syncer.stubs(:ignore_file?).returns(false)
            syncer.stubs(:broken_file?).with(file3).returns(true)
            syncer.stubs(:ignore_file?).with(file5).returns(true)

            theme.stubs(json_files: [file1, file2, file3, file4, file5])

            syncer.expects(:fetch_checksums!)
            syncer.expects(:enqueue_get).with([file1, file4])

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
