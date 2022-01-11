require "shopify_cli"

module ShopifyCLI
  module Commands
    class Switch < ShopifyCLI::Command
      options do |parser, flags|
        parser.on("-s", "--store=STORE") { |url| flags[:shop] = url }
        # backwards compatibility allow 'shop' for now
        parser.on("--shop=SHOP") { |url| flags[:shop] = url }
      end

      def call(*)
        if Shopifolk.acting_as_shopify_organization?
          @ctx.puts(@ctx.message("core.switch.disabled_as_shopify_org"))
          return
        end

        shop = if options.flags[:shop]
          Login.validate_shop(options.flags[:shop], context: @ctx)
        elsif (org_id = DB.get(:organization_id))
          res = ShopifyCLI::Tasks::SelectOrgAndShop.call(@ctx, organization_id: org_id)
          res[:shop_domain]
        else
          AdminAPI.get_shop_or_abort(@ctx)
          res = ShopifyCLI::Tasks::SelectOrgAndShop.call(@ctx)
          res[:shop_domain]
        end
        DB.set(shop: shop)
        IdentityAuth.new(ctx: @ctx).reauthenticate

        @ctx.puts(@ctx.message("core.switch.success", shop))
      end

      def self.help
        ShopifyCLI::Context.message("core.switch.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
