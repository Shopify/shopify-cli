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
              hot_reload_no_script = ::File.read("#{dir}/hot-reload-no-script.html")
              hot_reload_js = ::File.read("#{dir}/hot-reload-tae.js")
              hot_reload_script = [
                hot_reload_no_script,
                "<script>",
                params_js,
                hot_reload_js,
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
          end
        end
      end
    end
  end
end
