require "shopify_cli"

module ShopifyCli
  module Commands
    class Login < ShopifyCli::Command
      def call(*)
        IdentityAuth.new(ctx: @ctx).authenticate
      end

      def self.help
        ShopifyCli::Context.message("core.login.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
