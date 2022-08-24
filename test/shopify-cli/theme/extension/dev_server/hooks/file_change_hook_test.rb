# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/app_extension"
require "shopify_cli/theme/extension/dev_server"
require "shopify_cli/theme/dev_server/sse"
require "shopify_cli/theme/dev_server/hot_reload"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class FileChangeHookTest < Minitest::Test
            SSE = ::ShopifyCLI::Theme::DevServer::SSE
            HotReload = ::ShopifyCLI::Theme::DevServer::HotReload

            def setup
              super
              root = ShopifyCLI::ROOT + "/test/fixtures/extension"
              @ctx = TestHelpers::FakeContext.new(root: root)
              @extension = AppExtension.new(@ctx, root: root)
              @syncer = stub("Syncer", enqueue_files: true)
              @watcher = Watcher.new(@ctx, extension: @extension, syncer: @syncer)
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
              HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks,
                watcher: @watcher, mode: @mode)

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
              HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks,
                watcher: @watcher, mode: @mode)

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
              HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks,
                watcher: @watcher, mode: @mode)

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
              stack = HotReload.new(@ctx, app, broadcast_hooks: broadcast_hooks,
                watcher: @watcher, mode: @mode)
              request = Rack::MockRequest.new(stack)
              request.get(path).body
            end

            def broadcast_hooks
              file_change_hook = FileChangeHook.new(@ctx, extension: @extension)
              [file_change_hook]
            end
          end
        end
      end
    end
  end
end
