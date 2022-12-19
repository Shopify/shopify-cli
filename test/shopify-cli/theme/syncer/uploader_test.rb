# frozen_string_literal: true

require "test_helper"

require "shopify_cli/theme/syncer"
require "shopify_cli/theme/development_theme"

module ShopifyCLI
  module Theme
    class Syncer
      class UploaderTest < Minitest::Test
        def setup
          super

          stubs_cli_db(:development_theme_id, theme.id)
          stubs_cli_db(:shop, "dev-theme-server-store.myshopify.com")

          ShopifyCLI::AdminAPI
            .stubs(:rest_request)
            .returns([207, {}, {}])
        end

        def test_upload_when_it_bulk_uploads
          uploader.expects(:fetch_checksums!)
          uploader.expects(:delete_files!)

          # The sync upload must happen at the following order
          job_events_sequence = sequence("job events sequence")

          expect_job_request(3).in_sequence(job_events_sequence)
          expect_job_response.in_sequence(job_events_sequence)
          expect_shutdown.in_sequence(job_events_sequence)

          expect_job_request(4).in_sequence(job_events_sequence)
          expect_job_response.in_sequence(job_events_sequence)
          expect_shutdown.in_sequence(job_events_sequence)

          expect_job_request(2).in_sequence(job_events_sequence)
          expect_job_response.in_sequence(job_events_sequence)
          expect_shutdown.in_sequence(job_events_sequence)

          expect_job_request(3).in_sequence(job_events_sequence)
          expect_job_response.in_sequence(job_events_sequence)
          expect_shutdown.in_sequence(job_events_sequence)

          uploader.upload!
        end

        def test_upload_when_it_async_uploads
          syncer.stubs(:bulk_updates_activated?).returns(false)

          uploader.expects(:fetch_checksums!)
          uploader.expects(:delete_files!)

          # Handle conflicts
          uploader.expects(:enqueue_json_updates)

          # The async upload must be delegated to the syncer
          syncer.expects(:enqueue_updates)
          syncer.expects(:enqueue_updates)
          syncer.expects(:enqueue_updates)
          syncer.expects(:wait!)

          uploader.upload!
        end

        def test_delete_files
          syncer.checksums.stubs(:keys).returns([
            "assets/base.css",
            "assets/main.js",
            "config/conf.json",
          ])

          uploader.expects(:enqueue_deletes).with([
            theme["assets/base.css"],
            theme["assets/main.js"],
          ])

          uploader.expects(:enqueue_json_deletes).with([
            theme["config/conf.json"],
          ])

          uploader.delete_files!
        end

        def test_report
          file = theme["layout/theme.liquid"]
          error = StandardError.new

          syncer
            .stubs(:parse_api_errors)
            .with(file, error)
            .returns(["Unknown error"])

          syncer
            .expects(:report_file_error)
            .with(file, "layout/theme.liquid: Unknown error")

          uploader.send(:report, file, error)
        end

        private

        def uploader(delete_remote_assets: true, delay_low_priority_files: false)
          @uploader ||= Uploader.new(
            syncer,
            delete_remote_assets,
            delay_low_priority_files,
          )
        end

        def syncer
          @syncer ||= Syncer.new(
            ctx,
            theme: theme,
            include_filter: nil,
            ignore_filter: nil,
            overwrite_json: true,
            stable: false,
          ).tap do |syncer|
            syncer.stubs(:wait!).returns(nil)
          end
        end

        def theme
          @theme ||= DevelopmentTheme.new(ctx, id: "12345678", root: root)
        end

        def root
          @root ||= ShopifyCLI::ROOT + "/test/fixtures/theme"
        end

        def ctx
          @context
        end

        def stubs_cli_db(key, value = nil)
          ShopifyCLI::DB.stubs(:get).with(key).returns(value)
          ShopifyCLI::DB.stubs(:exists?).with(key).returns(true)
        end

        def expect_job_request(size)
          expect_debug_message(/\[BulkJob #\d+\] job request: size=#{size}/)
        end

        def expect_job_response
          expect_debug_message(/\[BulkJob #\d+\] job response: http_status=207/)
        end

        def expect_shutdown
          expect_debug_message(/\[Bulk\] shutdown/)
        end

        def expect_debug_message(pattern)
          ctx
            .expects(:debug)
            .with { |message| message.match?(pattern) }
        end
      end
    end
  end
end
