# frozen_string_literal: true
require_relative "../hot_reload/sections_index"

module ShopifyCLI
  module Theme
    class DevServer
      module Hooks
        class ReloadJSHook
          def initialize(ctx, theme:)
            @ctx = ctx
            @theme = theme
            @sections_index = HotReload::SectionsIndex.new(@theme)
          end

          def call(body:, dir:, mode:)
            @mode = mode
            hot_reload_no_script = ::File.read("#{dir}/hot-reload-no-script.html")
            hot_reload_js = ::File.read("#{dir}/hot-reload-theme.js")
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
            env[:section_names_by_type] = @sections_index.section_names_by_type

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
