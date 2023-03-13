# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServer
      class HotReloadTest < Minitest::Test
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

        def test_calls_broadcast_hooks_when_available
          app = -> { [200, {}, []] }
          @ctx.expects(:debug).with("Ran 1").once
          @ctx.expects(:debug).with("Ran 2").once
          @ctx.expects(:debug).with("Ran 3").once
          HotReload.new(@ctx, app, broadcast_hooks: broadcast_hook_mock, watcher: @watcher, mode: @mode)
          @watcher.changed
          @watcher.notify_observers([], [], [])
        end

        def test_calls_reload_script_injector
          app = lambda do |_env|
            [200, { "content-type" => "text/html" }, []]
          end
          correct_output = "<html><script>console.log('testing');</script></html>"
          stack = HotReload.new(@ctx, app, watcher: @watcher, mode: @mode,
            script_injector: reload_script_injector_mock(correct_output))
          request = Rack::MockRequest.new(stack)

          assert_equal(correct_output, request.get("/").body)
        end

        def test_does_not_call_reload_script_injector_for_web_pixels_manager_sandbox
          correct_output = "<html></html>"
          app = lambda do |_env|
            [200, { "content-type" => "text/html" }, [correct_output]]
          end
          stack = HotReload.new(@ctx, app, watcher: @watcher, mode: @mode)
          request = Rack::MockRequest.new(stack)

          assert_equal(correct_output, request.get("/web-pixels-manager@0.0.219/sandbox/").body)
          assert_equal(correct_output, request.get("/wpm@0.0.233@6b2037/sandbox/").body)
        end

        private

        def app
        end

        def reload_script_injector_mock(body)
          hook = mock("ScriptInjector", inject: body)
          hook
        end

        def broadcast_hook_mock
          hook1 = mock("BroadcastHook1", call: @ctx.debug("Ran 1"))
          hook2 = mock("BroadcastHook2", call: @ctx.debug("Ran 2"))
          hook3 = mock("BroadcastHook3", call: @ctx.debug("Ran 3"))
          [hook1, hook2, hook3]
        end
      end
    end
  end
end
