require "shopify_cli"

module ShopifyCli
  module Commands
    class Switch < ShopifyCli::Command
      options do |parser, flags|
        parser.on("--shop=SHOP") do |shop|
          flags[:shop] = shop
        end
        parser.on("--store=STORE") do |store|
          flags[:shop] = store
        end
      end

      def call(*)
        if Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("core.switch.disabled_as_shopify_org"))
          return
        end

        shop = if options.flags[:shop]
          Login.validate_shop(options.flags[:shop])
        elsif (org_id = DB.get(:organization_id))
          res = ShopifyCli::Tasks::SelectOrgAndShop.call(@ctx, organization_id: org_id)
          res[:shop_domain]
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
