# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/dev_server"
require "rack/mock"

module ShopifyCLI
  module Theme
    module DevServer
      class HotReloadTest < Minitest::Test
        def setup
          super
          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @theme = Theme.new(@ctx, root: root)
          @syncer = stub("Syncer", enqueue_uploads: true)
          @watcher = Watcher.new(@ctx, theme: @theme, syncer: @syncer)
        end

        def test_hot_reload_js_injected_if_html_request
          html = <<~HTML
            <html>
              <head></head>
              <body>
                <h1>Hello</h1>
              </body>
            </html>
          HTML

          reload_js = ::File.read(
            ::File.expand_path("lib/shopify_cli/theme/dev_server/hot-reload.js", ShopifyCLI::ROOT)
          )
          reload_script = "<script>\n#{reload_js}</script>"
          expected_html = <<~HTML
            <html>
              <head></head>
              <body>
                <h1>Hello</h1>
              #{reload_script}
            </body>
            </html>
          HTML

          response = serve(html, headers: { "content-type" => "text/html" })

          assert_equal(expected_html, response)
        end

        def test_does_not_inject_hot_reload_js_for_non_html_responses
          css = <<~CSS
            .body { color: red }
          CSS

          response = serve(css, headers: { "content-type" => "text/css" })

          assert_equal(css, response)
        end

        def test_streams_on_hot_reload_path
          SSE::Stream.any_instance.expects(:each).yields("")
          serve(path: "/hot-reload")
        end

        def test_broadcasts_watcher_events
          modified = ["style.css"]
          SSE::Streams.any_instance
            .expects(:broadcast)
            .with(JSON.generate(modified: modified))

          app = -> { [200, {}, []] }
          HotReload.new(@ctx, app, theme: @theme, watcher: @watcher)

          @watcher.changed
          @watcher.notify_observers(modified, [], [])
        end

        def test_doesnt_broadcast_watcher_events_when_the_list_is_empty
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
            theme: @theme,
            watcher: @watcher,
            ignore_filter: ignore_filter
          )

          @watcher.changed
          @watcher.notify_observers(modified, [], [])
        end

        private

        def serve(response_body = "", path: "/", headers: {})
          app = lambda do |_env|
            [200, headers, [response_body]]
          end
          stack = HotReload.new(@ctx, app, theme: @theme, watcher: @watcher)
          request = Rack::MockRequest.new(stack)
          request.get(path).body
        end
      end
    end
  end
end
