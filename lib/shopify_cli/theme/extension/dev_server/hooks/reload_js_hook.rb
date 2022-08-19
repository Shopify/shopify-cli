# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class ReloadJSHook
            def initialize(ctx)
              @ctx = ctx
            end

            def call(body:, dir:, mode:)
              @mode = mode
              @dir = dir
              hot_reload_script = [
                get_file("hot-reload-no-script.html"),
                "<script>",
                params_js,
                get_file("hot_reload.js"),
                get_file("sse_client.js"),
                get_file("theme_extension.js"),
                "</script>",
              ].join("\n")

              body = body.join.gsub("</body>", "#{hot_reload_script}\n</body>")

              [body]
            end

            private

            def params_js
              env = { mode: @mode }
              <<~JS
                (() => {
                  window.__SHOPIFY_CLI_ENV__ = #{env.to_json};
                })();
              JS
            end

            def get_file(filename)
              ::File.read("#{@dir}/hot_reload/resources/#{filename}")
            end
          end
        end
      end
    end
  end
end
