# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/extension/app_extension"
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

            def test_streams_on_hot_reload_path
              SSE::Stream.any_instance.expects(:each).yields("")
              serve(path: "/hot-reload")
            end

            def test_broadcasts_watcher_events_when_extension_file_modified
              modified = ["assets/block1.css"]

              SSE::Streams.any_instance
                .expects(:broadcast)
                .with(JSON.generate(modified: modified))

              hot_reload!

              watcher.changed
              watcher.notify_observers(modified, [], [])
            end

            def test_broadcasts_watcher_events_when_any_file_deleted
              deleted = ["announcement.liquid"]

              hook_sequence = sequence("wait and broadcast")
              hook.expects(:wait_blocking_operations).in_sequence(hook_sequence)
              hook.expects(:broadcast).in_sequence(hook_sequence)

              hot_reload!

              watcher.changed
              watcher.notify_observers([], [], deleted)
            end

            def test_broadcasts_watcher_events_when_any_file_added
              added = ["assets/block1.css"]

              hook_sequence = sequence("wait and broadcast")
              hook.expects(:wait_blocking_operations).in_sequence(hook_sequence)
              hook.expects(:broadcast).in_sequence(hook_sequence)

              hot_reload!

              watcher.changed
              watcher.notify_observers([], added, [])
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

              hot_reload!

              watcher.changed
              watcher.notify_observers(modified, [], [])
            end

            private

            def hot_reload!
              HotReload.new(
                ctx,
                app,
                broadcast_hooks: broadcast_hooks,
                watcher: watcher,
                mode: mode,
              )
            end

            def app
              -> { [200, {}, []] }
            end

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

            def watcher
              @watcher ||= Watcher.new(ctx, extension: extension, syncer: syncer)
            end

            def mode
              "off"
            end

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
              stack = HotReload.new(ctx, app, broadcast_hooks: broadcast_hooks,
                watcher: watcher, mode: mode)
              request = Rack::MockRequest.new(stack)
              request.get(path).body
            end

            def broadcast_hooks
              @broadcast_hooks ||= [hook]
            end

            def hook
              @hook ||= FileChangeHook.new(ctx, extension: extension, syncer: syncer)
            end
          end
        end
      end
    end
  end
end
