require "shopify_cli"
require "shopify-cli/theme/development_theme"

module ShopifyCli
  module Commands
    class Logout < ShopifyCli::Command
      def call(*)
        ShopifyCli::Theme::DevelopmentTheme.delete(@ctx)
        ShopifyCli::IdentityAuth.delete_tokens_and_keys
        ShopifyCli::DB.del(:shop) if ShopifyCli::DB.exists?(:shop)
        ShopifyCli::DB.del(:development_theme_id) if ShopifyCli::DB.exists?(:development_theme_id)
        ShopifyCli::DB.del(:development_theme_name) if ShopifyCli::DB.exists?(:development_theme_name)
        @ctx.puts(@ctx.message("core.logout.success"))
      end

      def self.help
        ShopifyCli::Context.message("core.logout.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
