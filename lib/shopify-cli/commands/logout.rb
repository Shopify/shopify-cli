require 'shopify_cli'

module ShopifyCli
  module Commands
    class Logout < ShopifyCli::Command
      LOGIN_TOKENS = [
        :identity_access_token, :identity_refresh_token, :identity_exchange_token,
        :admin_access_token, :admin_refresh_token, :admin_exchange_token
      ]

      def call(*)
        LOGIN_TOKENS.each do |token|
          ShopifyCli::DB.del(token) if ShopifyCli::DB.exists?(token)
        end
        @ctx.puts "Logged out of Organization and Shop"
      end

      def self.help
        <<~HELP
          Log out of a currently authenticated Organization and Shop, or clear invalid credentials
            Usage: {{command:#{ShopifyCli::TOOL_NAME} logout}}
        HELP
      end
    end
  end
end
