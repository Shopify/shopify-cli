# frozen_string_literal: true
require "test_helper"
require "timecop"
require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/extension/syncer"
require "shopify_cli/theme/extension/syncer/extension_serve_job"
require "project_types/extension/tasks/converters/version_converter"

module ShopifyCLI
  module Theme
    module Extension
      class SyncerTest < Minitest::Test
        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/extension"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @extension = AppExtension.new(@ctx, root: root, app_id: 1234)
          @extension.stubs(:extension_files).returns([])
          @extension_title = "Extension Testing"
          @project = generate_fake_project
          @specification_handler = generate_fake_spec_handler

          @syncer = Syncer.new(@ctx, extension: @extension, project: @project,
            specification_handler: @specification_handler)
        end

        def test_logs_success_when_draft_syncs_successfully
          # We need to have this return a time over the PUSH_INTERVAL
          @syncer.expects(:latest_sync).returns(frozen_time - Syncer::ExtensionServeJob::PUSH_INTERVAL)
          file_paths = %w[blocks/block1.liquid blocks/block2.liquid assets/block1.css]
          files = file_paths.map { |f| @extension[f] }

          graphql_success = {
            "data" => {
              "extensionUpdateDraft" => {
                "userErrors" => nil,
              },
            },
          }
          ShopifyCLI::PartnersAPI.expects(:query).returns(graphql_success)
          ::Extension::Tasks::Converters::VersionConverter.stubs(:from_hash).returns({})
          @ctx.expects(:puts)
            .with("12:30:59 {{green:Pushed}} {{>}} {{blue:'#{@extension_title}'}} to a draft").once

          files.each do |f|
            @ctx.expects(:puts)
              .with("{{blue:- #{f.relative_path}}}").once
          end

          @syncer.start
          time_freeze do
            @syncer.enqueue_files(files)
            @syncer.shutdown
          end
        end

        def test_logs_errors_when_draft_sync_fails
          # We need to have this return a time over the PUSH_INTERVAL
          @syncer.expects(:latest_sync).returns(frozen_time - Syncer::ExtensionServeJob::PUSH_INTERVAL)
          file_paths = %w[blocks/block1.liquid blocks/block2.liquid assets/block1.css]
          files = file_paths.map { |f| @extension[f] }

          error_msg = "[blocks/block1.liquid] This is a sample error message"
          graphql_error = {
            "data" => {
              "extensionUpdateDraft" => {
                "userErrors" => [{ "message" => error_msg }],
              },
            },
          }
          ShopifyCLI::PartnersAPI.expects(:query).returns(graphql_error)
          @ctx.expects(:puts)
            .with("12:30:59 {{red:Error}}  {{>}} {{blue:'#{@extension_title}'}} could not be pushed:").once
          Syncer::ExtensionServeJob.any_instance.expects(:print_file_error)
            .with(files[0], error_msg).once
          Syncer::ExtensionServeJob.any_instance.expects(:print_file_success)
            .with(files[1]).once
          Syncer::ExtensionServeJob.any_instance.expects(:print_file_success)
            .with(files[2]).once
          @syncer.start
          time_freeze do
            @syncer.enqueue_files(files)
            @syncer.shutdown
          end
        end

        private

        def time_freeze(&block)
          Timecop.freeze(frozen_time, &block)
        end

        def frozen_time
          Time.local(2000, 1, 1, 12, 30, 59)
        end

        def generate_fake_project
          mock(
            "Project",
            title: @extension_title,
            app: stub(api_key: 1234),
            registration_id: 4321,
          )
        end

        def generate_fake_spec_handler
          mock("Specification Handler", config: {}, extension_context: @ctx)
        end
      end
    end
  end
end
