require "shopify_cli"

module ShopifyCli
  module Commands
    class Logout < ShopifyCli::Command
      LOGIN_TOKENS = [
        :identity_access_token, :identity_refresh_token, :identity_exchange_token,
        :shopify_exchange_token
      ]

      def call(*)
        LOGIN_TOKENS.each do |token|
          ShopifyCli::DB.del(token) if ShopifyCli::DB.exists?(token)
        end
        @ctx.puts(@ctx.message("core.logout.success"))
      end

      def self.help
        ShopifyCli::Context.message("core.logout.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
