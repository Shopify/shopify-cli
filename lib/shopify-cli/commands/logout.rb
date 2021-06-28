require "shopify_cli"
require "shopify-cli/theme/development_theme"

module ShopifyCli
  module Commands
    class Logout < ShopifyCli::Command
      def call(*)
        try_delete_development_theme
        ShopifyCli::IdentityAuth.delete_tokens_and_keys
        ShopifyCli::DB.del(:shop) if has_shop?
        ShopifyCli::DB.del(:organization_id) if has_organization_id?
        ShopifyCli::Shopifolk.reset
        @ctx.puts(@ctx.message("core.logout.success"))
      end

      def self.help
        ShopifyCli::Context.message("core.logout.help", ShopifyCli::TOOL_NAME)
      end

      private

      def has_shop?
        ShopifyCli::DB.exists?(:shop)
      end

      def has_organization_id?
        ShopifyCli::DB.exists?(:organization_id)
      end

      def try_delete_development_theme
        return unless has_shop?

        ShopifyCli::Theme::DevelopmentTheme.delete(@ctx)
      rescue ShopifyCli::API::APIRequestError
        # Ignore since we can't delete it
      end
    end
  end
end
