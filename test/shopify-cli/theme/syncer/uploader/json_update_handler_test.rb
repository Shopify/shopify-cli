# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/uploader/json_update_handler"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class JsonUpdateHandlerTest < Minitest::Test
          include JsonUpdateHandler

          def setup
            super

            mock_files

            @files = [@file1, @file2, @file3, @file4, @file5]
          end

          def test_enqueue_json_updates_when_overwrite_json_true_theme_created_at_runtime_false
            @overwrite_json = true

            expects(:enqueue_updates).with(@files)
            expects(:handle_update_conflicts).never

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_overwrite_json_false_theme_created_at_runtime_true
            @overwrite_json = false
            @theme_created_at_runtime = true

            expects(:enqueue_updates).with(@files)
            expects(:handle_update_conflicts).never

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_overwrite_json_true_theme_created_at_runtime_true
            @overwrite_json = true
            @theme_created_at_runtime = true

            expects(:enqueue_updates).with(@files)
            expects(:handle_update_conflicts).never

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_keep_remote
            @overwrite_json = false

            @files.each do |file|
              Forms::SelectUpdateStrategy
                .expects(:ask)
                .with(ctx, [], file: file, exists_remotely: file != @file1)
                .returns(stub(strategy: :keep_remote))
            end

            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: false, value: nil))

            expects(:enqueue_get).with([@file2, @file3, @file4, @file5])
            expects(:delete_locally).with(@file1)

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_keep_local
            @overwrite_json = false
            @files.each do |file|
              Forms::SelectUpdateStrategy
                .expects(:ask)
                .with(ctx, [], file: file, exists_remotely: file != @file1)
                .returns(stub(strategy: :keep_local))
            end

            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: false, value: nil))

            expects(:enqueue_updates).with(@files)

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_union_merge
            @overwrite_json = false
            @files.each do |file|
              Forms::SelectUpdateStrategy
                .expects(:ask)
                .with(ctx, [], file: file, exists_remotely: file != @file1)
                .returns(stub(strategy: :union_merge))
            end

            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: false, value: nil))

            expects(:enqueue_union_merges).with([@file2, @file3, @file4, @file5])
            expects(:enqueue_updates).with([@file1])

            enqueue_json_updates(@files)
          end

          def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_apply_to_all_is_enabled
            @overwrite_json = false

            Forms::SelectUpdateStrategy.expects(:ask).never
            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: true, value: :keep_remote))

            expects(:enqueue_get).with([@file2, @file3, @file4, @file5])
            expects(:delete_locally).with(@file1)

            enqueue_json_updates(@files)
          end

          private

          def mock_files
            @file1 = stub(exist?: true, relative_path: "file1")
            @file2 = stub(exist?: true, relative_path: "file2")
            @file3 = stub(exist?: true, relative_path: "file3")
            @file4 = stub(exist?: true, relative_path: "file4")
            @file5 = stub(exist?: true, relative_path: "file5")

            @checksums = mock

            stubs(:ignore_file?).with(@file1).returns(false)
            stubs(:ignore_file?).with(@file2).returns(true)
            stubs(:ignore_file?).with(@file3).returns(false)
            stubs(:ignore_file?).with(@file4).returns(false)
            stubs(:ignore_file?).with(@file5).returns(false)

            @checksums.stubs(:[]).with("file1").returns(nil)
            @checksums.stubs(:[]).with("file2").returns("")
            @checksums.stubs(:[]).with("file3").returns("")
            @checksums.stubs(:[]).with("file4").returns("")
            @checksums.stubs(:[]).with("file5").returns("")
          end

          # Methods required in the host class/module to support the `JsonUpdateHandler`

          attr_reader :checksums, :theme

          def ctx
            @context
          end

          def overwrite_json?
            theme_created_at_runtime? || @overwrite_json
          end

          def theme_created_at_runtime?
            @theme_created_at_runtime ||= false
          end

          def enqueue_get(files); end
          def enqueue_updates(files); end
          def enqueue_deletes(files); end
          def enqueue_union_merges(files); end
          def delete_locally(file); end
          def ignore_file?(file); end
          def update(file); end
        end
      end
    end
  end
end
