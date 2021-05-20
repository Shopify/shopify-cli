require "shopify_cli"

module ShopifyCli
  module Commands
    class Switch < ShopifyCli::Command
      def call(*)
        AdminAPI.get_shop_or_abort(@ctx)
        res = ShopifyCli::Tasks::SelectOrgAndShop.call(@ctx)
        DB.set(shop: res[:shop_domain])
        IdentityAuth.new(ctx: @ctx).reauthenticate

        @ctx.puts(@ctx.message("core.switch.success", res[:shop_domain]))
      end

      def self.help
        ShopifyCli::Context.message("core.switch.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
