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
          @ignore_filter = IgnoreFilter.new(@root, patterns: ["foo/*"])
          @watcher = Watcher.new(@ctx, theme: @theme, syncer: @syncer, ignore_filter: @ignore_filter)
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

          @syncer.expects(:enqueue_updates).with([included_file])

          @watcher.upload_files_when_changed([included_path, ignored_path], [], [])
        end

        def test_filters_theme_files_correctly_by_relative_path
          relative_path = "layout/theme.liquid"
          absolute_path = ::File.join(@root, relative_path)

          @theme.expects(:theme_file?).with(absolute_path).returns(true)
          @ignore_filter.expects(:ignore?).with(relative_path)

          @watcher.filter_theme_files([absolute_path])
        end
      end
    end
  end
end
