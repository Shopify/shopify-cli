require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      SHOP_REGEX = /^[a-zA-Z0-9][a-zA-Z0-9-]*\.myshopify\.(com|io)$/

      options do |parser, flags|
        parser.on("--shop=SHOP") do |shop|
          flags[:shop] = shop
        end
        parser.on("--password=PASSWORD") do |password|
          flags[:password] = password
        end
      end

      def call(*)
        if Shopifolk.check
          @ctx.puts(@ctx.message("core.tasks.select_org_and_shop.identified_as_shopify"))
          message = @ctx.message("core.tasks.select_org_and_shop.first_party")
          if CLI::UI::Prompt.confirm(message, default: false)
            Shopifolk.act_as_shopify_organization
          else
            ShopifyCli::Shopifolk.reset
          end
        end
        shop = (options.flags[:shop] || @ctx.getenv("SHOPIFY_SHOP") || nil)
        ShopifyCli::DB.set(shop: validate_shop(shop)) unless shop.nil?

        # As password auth will soon be deprecated, we enable only in CI
        if @ctx.ci? && (password = options.flags[:password] || @ctx.getenv("SHOPIFY_PASSWORD"))
          ShopifyCli::DB.set(shopify_exchange_token: password)
        else
          IdentityAuth.new(ctx: @ctx).authenticate
        end
      end

      def self.help
        ShopifyCli::Context.message("core.login.help", ShopifyCli::TOOL_NAME)
      end

      private

      def validate_shop(shop)
        @ctx.abort(@ctx.message("core.login.invalid_shop", shop)) unless shop.match(SHOP_REGEX)
        shop
      end
    end
  end
end
