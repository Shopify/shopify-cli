# frozen_string_literal: true
require "test_helper"
require "rack/mock"
require "shopify_cli/theme/extension/dev_server"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class ReloadJSHookTest < Minitest::Test
            HotReload = ::ShopifyCLI::Theme::DevServer::HotReload
            def setup
              super
              root = ShopifyCLI::ROOT + "/test/fixtures/extension"
              @ctx = TestHelpers::FakeContext.new(root: root)
              @extension = AppExtension.new(@ctx, root: root, id: 1234)
              @syncer = stub("Syncer", enqueue_files: true)
              @watcher = Watcher.new(@ctx, extension: @extension, syncer: @syncer)
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

              params_js = <<~JS
                (() => {
                  window.__SHOPIFY_CLI_ENV__ = {"mode":"off"};
                })();
              JS

              reload_js = ::File.read(
                ::File.expand_path("lib/shopify_cli/theme/dev_server/hot-reload-tae.js", ShopifyCLI::ROOT)
              )
              hot_reload_no_script = ::File.read(
                ::File.expand_path("lib/shopify_cli/theme/dev_server/hot-reload-no-script.html", ShopifyCLI::ROOT)
              )

              injected_script = "<script>\n#{params_js}\n#{reload_js}\n</script>"

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
              js_hook = ReloadJSHook.new(@ctx)
              stack = HotReload.new(@ctx, app, watcher: @watcher, mode: @mode,
                js_hook: js_hook)
              request = Rack::MockRequest.new(stack)
              request.get(path).body
            end
          end
        end
      end
    end
  end
end
