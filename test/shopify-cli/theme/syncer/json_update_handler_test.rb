# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/json_update_handler"

module ShopifyCLI
  module Theme
    class Syncer
      class JsonUpdateHandlerTest < Minitest::Test
        include JsonUpdateHandler

        def setup
          super

          mock_files

          @ctx = @context
          @files = [@file1, @delayed_file1, @file2, @delayed_file2, @file3, @file4, @file5]
          @to_update = [@file1, @file3, @file5, @delayed_file1, @delayed_file2]
        end

        def test_enqueue_json_updates_when_it_should_overwrite_json_files
          @overwrite_json = true

          expects(:enqueue_updates).with(@to_update)

          enqueue_json_updates(@files)
        end

        def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_keep_remote
          @overwrite_json = false
          @to_update.each do |file|
            Forms::SelectUpdateStrategy
              .expects(:ask)
              .with(@ctx, [], file: file)
              .returns(stub(strategy: :keep_remote))
          end

          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_update.size)
            .returns(stub(apply?: false, value: nil))

          expects(:enqueue_get).with([@file3, @file5, @delayed_file1, @delayed_file2])
          expects(:delete_locally).with(@file1)

          enqueue_json_updates(@files)
        end

        def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_keep_local
          @overwrite_json = false
          @to_update.each do |file|
            Forms::SelectUpdateStrategy
              .expects(:ask)
              .with(@ctx, [], file: file)
              .returns(stub(strategy: :keep_local))
          end

          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_update.size)
            .returns(stub(apply?: false, value: nil))

          expects(:enqueue_updates).with(@to_update)

          enqueue_json_updates(@files)
        end

        def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_strategy_is_union_merge
          @overwrite_json = false
          @to_update.each do |file|
            Forms::SelectUpdateStrategy
              .expects(:ask)
              .with(@ctx, [], file: file)
              .returns(stub(strategy: :union_merge))
          end

          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_update.size)
            .returns(stub(apply?: false, value: nil))

          expects(:enqueue_union_merges).with([@file3, @file5, @delayed_file1, @delayed_file2])
          expects(:enqueue_updates).with([@file1])

          enqueue_json_updates(@files)
        end

        def test_enqueue_json_updates_when_it_should_not_overwrite_json_files_and_apply_to_all_is_enabled
          @overwrite_json = false

          Forms::SelectUpdateStrategy.expects(:ask).never
          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_update.size)
            .returns(stub(apply?: true, value: :keep_remote))

          expects(:enqueue_get).with([@file3, @file5, @delayed_file1, @delayed_file2])
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
          @delayed_file1 = stub(exist?: true, relative_path: "delayed_file1")
          @delayed_file2 = stub(exist?: true, relative_path: "delayed_file2")

          @checksums = mock
          @theme = {
            "config/settings_schema.json" => @delayed_file1,
            "config/settings_data.json" => @delayed_file2,
          }

          stubs(:ignore_file?).with(@file1).returns(false)
          stubs(:ignore_file?).with(@file2).returns(true)
          stubs(:ignore_file?).with(@file3).returns(false)
          stubs(:ignore_file?).with(@file4).returns(false)
          stubs(:ignore_file?).with(@file5).returns(false)
          stubs(:ignore_file?).with(@delayed_file1).returns(false)
          stubs(:ignore_file?).with(@delayed_file2).returns(false)

          @checksums.stubs(:file_has_changed?).with(@file1).returns(true)
          @checksums.stubs(:file_has_changed?).with(@file2).returns(true)
          @checksums.stubs(:file_has_changed?).with(@file3).returns(true)
          @checksums.stubs(:file_has_changed?).with(@file4).returns(false)
          @checksums.stubs(:file_has_changed?).with(@file5).returns(true)
          @checksums.stubs(:file_has_changed?).with(@delayed_file1).returns(true)
          @checksums.stubs(:file_has_changed?).with(@delayed_file2).returns(true)

          @checksums.stubs(:[]).with("file1").returns(nil)
          @checksums.stubs(:[]).with("file2").returns("")
          @checksums.stubs(:[]).with("file3").returns("")
          @checksums.stubs(:[]).with("file4").returns("")
          @checksums.stubs(:[]).with("file5").returns("")
          @checksums.stubs(:[]).with("delayed_file1").returns("")
          @checksums.stubs(:[]).with("delayed_file2").returns("")
        end

        # Methods required in the host class/module to support the `JsonUpdateHandler`

        attr_reader :checksums, :theme

        def overwrite_json?
          @overwrite_json
        end

        def enqueue_get(files); end
        def enqueue_updates(files); end
        def enqueue_deletes(files); end
        def enqueue_union_merges(files); end
        def delete_locally(file); end
        def ignore_file?(file); end
      end
    end
  end
end
