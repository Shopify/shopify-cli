# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Extension
      class DevServer
        module Hooks
          class ReloadJSHook < ShopifyCLI::Theme::DevServer::Hooks::ReloadJSHook
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
