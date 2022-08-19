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
            @dir = dir
            hot_reload_script = [
              get_file("hot-reload-no-script.html"),
              "<script>",
              params_js,
              get_file("hot_reload.js"),
              get_file("sse_client.js"),
              get_file("theme.js"),
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

          def get_file(filename)
            ::File.read("#{@dir}/hot_reload/resources/#{filename}")
          end
        end
      end
    end
  end
end
