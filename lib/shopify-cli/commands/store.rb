require "shopify_cli"

module ShopifyCli
  module Commands
    class Store < ShopifyCli::Command
      def call(_args, _name)
        @ctx.puts(@ctx.message("core.store.shop", ShopifyCli::AdminAPI.get_shop_or_abort(@ctx)))
      end

      def self.help
        ShopifyCli::Context.message("core.store.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
