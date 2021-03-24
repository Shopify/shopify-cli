require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      SHOP_REGEX = /^[a-zA-Z0-9][a-zA-Z0-9-]*\.myshopify\.(com|io)$/

      options do |parser, flags|
        parser.on("--shop=SHOP") do |shop|
          flags[:shop] = shop
        end
      end

      def call(*)
        shop = options.flags[:shop] || CLI::UI::Prompt.ask(@ctx.message("core.login.shop_prompt"), allow_empty: false)
        ShopifyCli::DB.set(shop: validate_shop(shop))
        IdentityAuth.new(ctx: @ctx).authenticate
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
