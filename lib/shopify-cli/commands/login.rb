require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      def call(*)
        IdentityAuth.new(ctx: @ctx).authenticate
        puts ShopifyCli::DB.get('storefront-renderer-production_exchange_token'.to_sym)
      end

      def self.help
        ShopifyCli::Context.message("core.login.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
