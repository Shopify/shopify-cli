require 'shopify_cli'

module ShopifyCli
  module Commands
    class Logout < ShopifyCli::Command
      LOGIN_TOKENS = %i[
        identity_access_token
        identity_refresh_token
        identity_exchange_token
        admin_access_token
        admin_refresh_token
        admin_exchange_token
      ]

      def call(*)
        LOGIN_TOKENS.each { |token| ShopifyCli::DB.del(token) if ShopifyCli::DB.exists?(token) }
        @ctx.puts(@ctx.message('core.logout.success'))
      end

      def self.help
        ShopifyCli::Context.message('core.logout.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
