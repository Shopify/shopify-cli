# frozen_string_literal: true

require "shopify_cli/theme/dev_server/hot_reload"

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        class HotReload < ShopifyCLI::Theme::DevServer::HotReload; end
      end
    end
  end
end
