# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServer
      module Hooks
        class FileChangeHookTest < Minitest::Test
          def setup
            super
            root = ShopifyCLI::ROOT + "/test/fixtures/theme"
            @ctx = TestHelpers::FakeContext.new(root: root)
            @theme = Theme.new(@ctx, root: root)
            @syncer = stub("Syncer", enqueue_uploads: true, enqueue_deletes: true, enqueue_updates: true,
              ignore_file?: false)
            @syncer.stubs(remote_file?: true)
            @watcher = Watcher.new(@ctx, theme: @theme, syncer: @syncer)
            @mode = "off"
          end

          def test_streams_on_hot_reload_path
            SSE::Stream.any_instance.expects(:each).yields("")
            serve(path: "/hot-reload")
          end

          def test_broadcasts_watcher_events_when_file_modified
            modified = ["style.css"]
            SSE::Streams.any_instance
              .expects(:broadcast)
              .with(JSON.generate(modified: modified))

            app = -> { [200, {}, []] }
            HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks, watcher: @watcher, mode: @mode)

            @watcher.changed
            @watcher.notify_observers(modified, [], [])
          end

          def test_broadcasts_watcher_events_when_file_deleted
            deleted = ["announcement.liquid"]
            HotReload::RemoteFileDeleter
              .stubs(:new)
              .returns(remote_file_deleter)

            SSE::Streams.any_instance
              .expects(:broadcast)
              .with(JSON.generate(reload_page: true))

            app = -> { [200, {}, []] }
            HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks, watcher: @watcher, mode: @mode)

            @watcher.changed
            @watcher.notify_observers([], [], deleted)
          end

          def test_doesnt_broadcast_watcher_events_when_modified_list_is_empty
            root_path = Pathname.new(__dir__)
            ignore_filter = ShopifyCLI::Theme::IgnoreFilter.new(root_path, patterns: ["ignored/**"])
            modified = ["ignored/style.css"]
            SSE::Streams.any_instance
              .expects(:broadcast)
              .with(JSON.generate(modified: modified))
              .never

            app = -> { [200, {}, []] }
            HotReload.new(
              @ctx, app,
              broadcast_hooks: broadcast_hooks(ignore_filter),
              watcher: @watcher,
              mode: @mode,
            )

            @watcher.changed
            @watcher.notify_observers(modified, [], [])
          end

          def test_doesnt_broadcast_watcher_events_when_deleted_list_is_empty
            root_path = Pathname.new(__dir__)
            ignore_filter = ShopifyCLI::Theme::IgnoreFilter.new(root_path, patterns: ["ignored/**"])
            deleted = ["ignored/announcement.liquid"]
            SSE::Streams.any_instance
              .expects(:broadcast)
              .with(JSON.generate(reload_page: true))
              .never

            app = -> { [200, {}, []] }
            HotReload.new(
              @ctx, app,
              broadcast_hooks: broadcast_hooks(ignore_filter),
              watcher: @watcher,
              mode: @mode,
            )

            @watcher.changed
            @watcher.notify_observers([], [], deleted)
          end

          def test_doesnt_broadcast_watcher_events_when_modified_file_is_a_liquid_css
            modified = ["assets/generated.css.liquid"]
            HotReload::RemoteFileReloader
              .stubs(:new)
              .returns(remote_file_reloader)
            SSE::Streams.any_instance
              .expects(:broadcast)
              .with(JSON.generate(modified: modified))
              .never

            app = -> { [200, {}, []] }
            HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks, watcher: @watcher, mode: @mode)

            @watcher.changed
            @watcher.notify_observers(modified, [], [])
          end

          private

          def remote_file_reloader
            reloader = mock("Reloader")
            reloader.stubs(reload: nil)
            reloader
          end

          def remote_file_deleter
            deleter = mock("Deleter")
            deleter.stubs(delete: nil)
            deleter
          end

          def serve(response_body = "", path: "/", headers: {})
            app = lambda do |_env|
              [200, headers, [response_body]]
            end
            stack = HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks, watcher: @watcher, mode: @mode)
            request = Rack::MockRequest.new(stack)
            request.get(path).body
          end

          def broadcast_hooks(ignore_filter = nil)
            file_change_hook = FileChangeHook.new(@ctx, theme: @theme, ignore_filter: ignore_filter)
            [file_change_hook]
          end
        end
      end
    end
  end
end
