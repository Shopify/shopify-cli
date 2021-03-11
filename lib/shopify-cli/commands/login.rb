require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      def call(*)
        shop = CLI::UI::Prompt.ask(@ctx.message(
          "What store are you connecting to? (e.g. https://shop1.myshopify.io/admin)"
        ),
          allow_empty: false)
        IdentityAuth.new(ctx: @ctx).authenticate(shop: shop)
      end

      def self.help
        ShopifyCli::Context.message("core.login.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
