# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/dev_server"

module ShopifyCLI
  module Theme
    class DevServer
      class HotReload
        class ScriptInjectorTest < Minitest::Test
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

          def test_hot_reload_js_injected_if_html_request
            html = <<~HTML
              <html>
                <head></head>
                <body>
                  <h1>Hello</h1>
                </body>
              </html>
            HTML

            javascript_inline = <<~JS
              (() => {
                window.__SHOPIFY_CLI_ENV__ = {"mode":"off","section_names_by_type":{"main-blog":["main"]}};
              })();
            JS

            hot_reload_js = ::File.read(
              ::File.expand_path("lib/shopify_cli/theme/dev_server/hot_reload/resources/hot_reload.js",
                ShopifyCLI::ROOT)
            )
            theme_js = ::File.read(
              ::File.expand_path("lib/shopify_cli/theme/dev_server/hot_reload/resources/theme.js", ShopifyCLI::ROOT)
            )
            sse_client_js = ::File.read(
              ::File.expand_path("lib/shopify_cli/theme/dev_server/hot_reload/resources/sse_client.js",
                ShopifyCLI::ROOT)
            )
            hot_reload_no_script = ::File.read(
              ::File.expand_path("lib/shopify_cli/theme/dev_server/hot_reload/resources/hot-reload-no-script.html",
                ShopifyCLI::ROOT)
            )

            injected_script = [
              "<script>",
              "(() => {",
              javascript_inline,
              hot_reload_js,
              sse_client_js,
              theme_js,
              "})();",
              "</script>",
            ].join("\n")

            expected_html = <<~HTML
              <html>
                <head></head>
                <body>
                  <h1>Hello</h1>
                #{hot_reload_no_script}
              #{injected_script}
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

          private

          def serve(response_body = "", path: "/", headers: {})
            app = lambda do |_env|
              [200, headers, [response_body]]
            end
            script_injector = ScriptInjector.new(@ctx, theme: @theme)
            stack = HotReload.new(@ctx, app, watcher: @watcher, mode: @mode, script_injector: script_injector)
            request = Rack::MockRequest.new(stack)
            request.get(path).body
          end
        end
      end
    end
  end
end
