require "shopify_cli"

module ShopifyCli
  module Commands
    class Switch < ShopifyCli::Command
      options do |parser, flags|
        parser.on("--shop=SHOP") do |shop|
          flags[:shop] = shop
        end
      end

      def call(*)
        shop = if options.flags[:shop]
          Login.validate_shop(options.flags[:shop])
        else
          AdminAPI.get_shop_or_abort(@ctx)
          res = ShopifyCli::Tasks::SelectOrgAndShop.call(@ctx)
          res[:shop_domain]
        end
        DB.set(shop: shop)
        IdentityAuth.new(ctx: @ctx).reauthenticate

        @ctx.puts(@ctx.message("core.switch.success", shop))
      end

      def self.help
        ShopifyCli::Context.message("core.switch.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
