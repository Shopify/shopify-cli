require "shopify_cli"

module ShopifyCLI
  module Commands
    class Store < ShopifyCLI::Command
      def call(_args, _name)
        @ctx.puts(@ctx.message("core.store.shop", ShopifyCLI::AdminAPI.get_shop_or_abort(@ctx)))
      end

      def self.help
        ShopifyCLI::Context.message("core.store.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
