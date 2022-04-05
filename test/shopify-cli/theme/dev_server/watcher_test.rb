# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"
require "shopify_cli/theme/dev_server/watcher"

module ShopifyCLI
  module Theme
    module DevServer
      class WatcherTest < Minitest::Test
        def setup
          super
          @root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          @ctx = TestHelpers::FakeContext.new(root: @root)
          @theme = Theme.new(@ctx, root: @root)
          @syncer = stub("Syncer", enqueue_uploads: true, enqueue_updates: true)
          @watcher = Watcher.new(@ctx, theme: @theme, syncer: @syncer)
        end

        def test_upload_files_when_changed
          included_path = "layout/theme.liquid"
          included_file = @theme[included_path]
          ignored_path = "foo/bar.liquid"
          ignored_file = @theme[ignored_path]

          @theme.expects(:theme_file?).with(included_path).returns(true)
          @theme.expects(:theme_file?).with(ignored_path).returns(true)

          @theme.expects(:[]).with(included_path).returns(included_file)
          @theme.expects(:[]).with(ignored_path).returns(ignored_file)

          @syncer.expects(:ignore_file?).with(included_file).returns(false)
          @syncer.expects(:ignore_file?).with(ignored_file).returns(true)

          @syncer.expects(:enqueue_updates).with([included_file])

          @watcher.upload_files_when_changed([included_path, ignored_path], [], [])
        end
      end
    end
  end
end
