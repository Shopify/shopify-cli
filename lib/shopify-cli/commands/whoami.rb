require "shopify_cli"

module ShopifyCli
  module Commands
    class Whoami < ShopifyCli::Command
      def call(_args, _name)
        shop = ShopifyCli::DB.get(:shop)
        org_id = ShopifyCli::DB.get(:organization_id)
        org = ShopifyCli::PartnersAPI::Organizations.fetch(@ctx, id: org_id) unless org_id.nil?

        output = if shop.nil? && org.nil?
          @ctx.message("core.whoami.not_logged_in", ShopifyCli::TOOL_NAME)
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
        ShopifyCli::Context.message("core.whoami.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
