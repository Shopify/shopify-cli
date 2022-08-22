# frozen_string_literal: true

require "shopify_cli/theme/dev_server/hot_reload/script_injector"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        class HotReload < ShopifyCLI::Theme::DevServer::HotReload
          class ScriptInjector < ShopifyCLI::Theme::DevServer::HotReload::ScriptInjector
            private

            def javascript_files
              %w(hot_reload.js sse_client.js theme_extension.js)
            end

            def javascript_inline
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
