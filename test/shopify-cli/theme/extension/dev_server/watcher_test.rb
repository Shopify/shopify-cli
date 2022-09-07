# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/extension/dev_server/watcher"
require "shopify_cli/theme/extension/app_extension"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        class WatcherTest < Minitest::Test
          def setup
            super
            @watcher = Watcher.new(ctx, extension: extension, syncer: syncer, poll: false)
          end

          def test_notify_updates
            block1_file = extension["blocks/block1.liquid"]

            modified = ["blocks/block1.liquid", ".env"]
            added = ["blocks/block1.liquid", ".config.json"]
            removed = ["blocks/block1.liquid"]

            syncer.expects(:enqueue_updates).with([block1_file])
            syncer.expects(:enqueue_creates).with([block1_file])
            syncer.expects(:enqueue_deletes).with([block1_file])

            @watcher.notify_updates(modified, added, removed)
          end

          private

          def root
            @root ||= ShopifyCLI::ROOT + "/test/fixtures/extension"
          end

          def ctx
            @ctx ||= TestHelpers::FakeContext.new(root: root)
          end

          def extension
            @extension ||= AppExtension.new(ctx, root: root)
          end

          def syncer
            @syncer ||= stub(
              "Syncer",
              enqueue_creates: nil,
              enqueue_updates: nil,
              enqueue_deletes: nil,
              any_blocking_operation?: false,
            )
          end
        end
      end
    end
  end
end
