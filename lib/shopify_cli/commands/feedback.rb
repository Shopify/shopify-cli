require "shopify_cli"

module ShopifyCLI
  module Commands
    class Feedback < ShopifyCLI::Command

      def call(*)
        url = 'https://github.com/Shopify/shopify-cli/issues/new'

        @ctx.open_url!(url)
        # @ctx.puts(@ctx.message("Press any key to open a feedback form in a browser"))

        # CLI::UI.ask('Press any key to open a feedback form in a browser')

        # system("open", url)

        # shop = (options.flags[:shop] || @ctx.getenv("SHOPIFY_SHOP" || nil))
        # ShopifyCLI::DB.set(shop: self.class.validate_shop(shop)) unless shop.nil?
        #
        # if shop.nil? && Shopifolk.check
        #   Shopifolk.reset
        #   @ctx.puts(@ctx.message("core.tasks.select_org_and_shop.identified_as_shopify"))
        #   message = @ctx.message("core.tasks.select_org_and_shop.first_party")
        #   if CLI::UI::Prompt.confirm(message, default: false)
        #     Shopifolk.act_as_shopify_organization
        #   end
        # end
        #
        # # As password auth will soon be deprecated, we enable only in CI
        # if @ctx.ci? && (password = options.flags[:password] || @ctx.getenv("SHOPIFY_PASSWORD"))
        #   ShopifyCLI::DB.set(shopify_exchange_token: password)
        # else
        #   IdentityAuth.new(ctx: @ctx).authenticate
        #   org = select_organization
        #   ShopifyCLI::DB.set(organization_id: org["id"].to_i) unless org.nil?
        #   Whoami.call([], "whoami")
        # end
      end
    end
  end
end
