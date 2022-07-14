# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/json_delete_handler"

module ShopifyCLI
  module Theme
    class Syncer
      class JsonDeleteHandlerTest < Minitest::Test
        include JsonDeleteHandler

        def setup
          super

          mock_files

          @ctx = @context
          @files = [@file1, @file2, @file3]
          @to_delete = [@file1, @file3]
        end

        def test_enqueue_json_deletes_when_overwrite_json_true_theme_created_at_runtime_true
          @overwrite_json = true
          @theme_created_at_runtime = true

          expects(:enqueue_deletes).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_when_overwrite_json_false_theme_created_at_runtime_true
          @overwrite_json = false
          @theme_created_at_runtime = true

          expects(:enqueue_deletes).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_when_overwrite_json_true_theme_created_at_runtime_false
          @overwrite_json = true

          expects(:enqueue_deletes).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_does_not_delete_when_overwrite_json_false_theme_created_at_runtime_false
          @overwrite_json = false

          expects(:enqueue_deletes).never
          expects(:handle_delete_conflicts)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_when_it_should_not_overwrite_json_files_and_strategy_is_delete
          @overwrite_json = false
          @to_delete.each do |file|
            Forms::SelectDeleteStrategy
              .expects(:ask)
              .with(@ctx, [], file: file)
              .returns(stub(strategy: :delete))
          end

          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_delete.size)
            .returns(stub(apply?: false, value: nil))

          expects(:enqueue_deletes).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_when_it_should_not_overwrite_json_files_and_strategy_is_restore
          @overwrite_json = false
          @to_delete.each do |file|
            Forms::SelectDeleteStrategy
              .expects(:ask)
              .with(@ctx, [], file: file)
              .returns(stub(strategy: :restore))
          end

          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_delete.size)
            .returns(stub(apply?: false, value: nil))

          expects(:enqueue_get).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        def test_enqueue_json_deletes_when_it_should_not_overwrite_json_files_and_apply_to_all_is_enabled
          @overwrite_json = false

          Forms::SelectDeleteStrategy.expects(:ask).never
          Forms::ApplyToAll
            .expects(:new)
            .with(@ctx, @to_delete.size)
            .returns(stub(apply?: true, value: :delete))

          expects(:enqueue_deletes).with(@to_delete)

          enqueue_json_deletes(@files)
        end

        private

        def mock_files
          @file1 = stub(exist?: true, relative_path: "file1")
          @file2 = stub(exist?: true, relative_path: "file2")
          @file3 = stub(exist?: true, relative_path: "file3")
          stubs(:ignore_file?).with(@file1).returns(false)
          stubs(:ignore_file?).with(@file2).returns(true)
          stubs(:ignore_file?).with(@file3).returns(false)
        end

        # Methods required in the host class/module to support the `JsonDeleteHandler`

        def overwrite_json?
          theme_created_at_runtime? || @overwrite_json
        end

        def theme_created_at_runtime?
          @theme_created_at_runtime ||= false
        end

        def enqueue_deletes(files); end
        def enqueue_get(files); end
        def ignore_file?(file); end
      end
    end
  end
end
