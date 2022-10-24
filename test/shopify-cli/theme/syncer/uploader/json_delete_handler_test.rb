# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer/uploader/json_delete_handler"

module ShopifyCLI
  module Theme
    class Syncer
      class Uploader
        class JsonDeleteHandlerTest < Minitest::Test
          include JsonDeleteHandler

          def setup
            super

            mock_files

            @files = [@file1, @file2, @file3]
          end

          def test_enqueue_json_deletes_when_overwrite_json_true_theme_created_at_runtime_true
            @overwrite_json = true
            @theme_created_at_runtime = true

            expects(:enqueue_deletes).with(@files)
            expects(:handle_delete_conflicts).never

            enqueue_json_deletes(@files)
          end

          def test_enqueue_json_deletes_when_overwrite_json_false_theme_created_at_runtime_true
            @overwrite_json = false
            @theme_created_at_runtime = true

            expects(:enqueue_deletes).with(@files)
            expects(:handle_delete_conflicts).never

            enqueue_json_deletes(@files)
          end

          def test_enqueue_json_deletes_when_overwrite_json_true_theme_created_at_runtime_false
            @overwrite_json = true

            expects(:enqueue_deletes).with(@files)
            expects(:handle_delete_conflicts).never

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

            @files.each do |file|
              Forms::SelectDeleteStrategy
                .expects(:ask)
                .with(ctx, [], file: file)
                .returns(stub(strategy: :delete))
            end

            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: false, value: nil))

            expects(:enqueue_deletes).with(@files)

            enqueue_json_deletes(@files)
          end

          def test_enqueue_json_deletes_when_it_should_not_overwrite_json_files_and_strategy_is_restore
            @overwrite_json = false

            @files.each do |file|
              Forms::SelectDeleteStrategy
                .expects(:ask)
                .with(ctx, [], file: file)
                .returns(stub(strategy: :restore))
            end

            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: false, value: nil))

            expects(:enqueue_get).with(@files)

            enqueue_json_deletes(@files)
          end

          def test_enqueue_json_deletes_when_it_should_not_overwrite_json_files_and_apply_to_all_is_enabled
            @overwrite_json = false

            Forms::SelectDeleteStrategy
              .expects(:ask)
              .never
            Forms::ApplyToAll
              .expects(:new)
              .with(ctx, @files.size)
              .returns(stub(apply?: true, value: :delete))

            expects(:enqueue_deletes).with(@files)

            enqueue_json_deletes(@files)
          end

          private

          def mock_files
            @file1 = stub(exist?: true, relative_path: "file1")
            @file2 = stub(exist?: true, relative_path: "file2")
            @file3 = stub(exist?: true, relative_path: "file3")
          end

          # Methods required in the host class/module to support the `JsonDeleteHandler`

          def ctx
            @context
          end

          def overwrite_json?
            theme_created_at_runtime? || @overwrite_json
          end

          def theme_created_at_runtime?
            @theme_created_at_runtime ||= false
          end

          def enqueue_deletes(files); end
          def enqueue_get(files); end
        end
      end
    end
  end
end
