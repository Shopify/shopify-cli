require "shopify_cli"

module ShopifyCLI
  module Commands
    class Whoami < ShopifyCLI::Command
      def call(_args, _name)
        shop = ShopifyCLI::DB.get(:shop)
        org_id = ShopifyCLI::DB.get(:organization_id)
        org = ShopifyCLI::PartnersAPI::Organizations.fetch(@ctx, id: org_id) unless org_id.nil?

        output = if shop.nil? && org.nil?
          @ctx.message("core.whoami.not_logged_in", ShopifyCLI::TOOL_NAME)
        elsif !shop.nil? && org.nil?
          @ctx.message("core.whoami.logged_in_shop_only", shop)
        elsif shop.nil? && !org.nil?
          @ctx.message("core.whoami.logged_in_partner_only", org["businessName"])
        else
          @ctx.message("core.whoami.logged_in_partner_and_shop", shop, org["businessName"])
        end
        @ctx.puts(output)
      end

      def self.help
        ShopifyCLI::Context.message("core.whoami.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
