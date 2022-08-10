require "shopify_cli"
require "shopify_cli/theme/development_theme"
require "shopify_cli/theme/extension/host_theme"

module ShopifyCLI
  module Commands
    class Logout < ShopifyCLI::Command
      def call(*)
        try_delete_development_theme
        try_delete_host_theme

        ShopifyCLI::IdentityAuth.delete_tokens_and_keys
        ShopifyCLI::DB.del(:shop) if has_shop?
        ShopifyCLI::DB.del(:organization_id) if has_organization_id?
        ShopifyCLI::Shopifolk.reset
        @ctx.puts(@ctx.message("core.logout.success"))
      end

      def self.help
        ShopifyCLI::Context.message("core.logout.help", ShopifyCLI::TOOL_NAME)
      end

      private

      def has_shop?
        ShopifyCLI::DB.exists?(:shop)
      end

      def has_organization_id?
        ShopifyCLI::DB.exists?(:organization_id)
      end

      def try_delete_development_theme
        return unless has_shop?

        ShopifyCLI::Theme::DevelopmentTheme.delete(@ctx)
      rescue ShopifyCLI::API::APIRequestError, ShopifyCLI::Abort, ShopifyCLI::AbortSilent => e
        @ctx.debug("[Logout Error]: #{e.message}")
      end

      def try_delete_host_theme
        return unless has_shop?

        ShopifyCLI::Theme::Extension::HostTheme.delete(@ctx)
      rescue ShopifyCLI::API::APIRequestError, ShopifyCLI::Abort, ShopifyCLI::AbortSilent => e
        @ctx.debug("[Logout Error]: #{e.message}")
      end
    end
  end
end
