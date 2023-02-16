# frozen_string_literal: true
require_relative "../hot_reload/sections_index"

module ShopifyCLI
  module Theme
    class DevServer
      class HotReload
        class ScriptInjector
          def initialize(ctx, theme: nil)
            @ctx = ctx
            @theme = theme
            @sections_index = HotReload::SectionsIndex.new(theme) unless theme.nil?
          end

          def inject(body:, dir:, mode:)
            @mode = mode
            @dir = dir
            hot_reload_script = [
              read("hot-reload-no-script.html"),
              "<script>",
              "(() => {",
              javascript_inline,
              *javascript_files.map { |file| read(file) },
              "})();",
              "</script>",
            ].join("\n")

            body = body.join.sub("</body>", "#{hot_reload_script}\n</body>")

            [body]
          end

          private

          def javascript_files
            %w(hot_reload.js sse_client.js theme.js)
          end

          def javascript_inline
            env = { mode: @mode }
            env[:section_names_by_type] = @sections_index.section_names_by_type

            <<~JS
              (() => {
                window.__SHOPIFY_CLI_ENV__ = #{env.to_json};
              })();
            JS
          end

          def read(filename)
            ::File.read("#{@dir}/hot_reload/resources/#{filename}")
          end
        end
      end
    end
  end
end
