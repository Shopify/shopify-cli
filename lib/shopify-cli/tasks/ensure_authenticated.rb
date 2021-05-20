require "shopify_cli"

module ShopifyCli
  module Tasks
    class EnsureAuthenticated < ShopifyCli::Task
      def call(ctx)
        ctx.abort(
          ctx.message("core.identity_auth.login_prompt", ShopifyCli::TOOL_NAME)
        ) unless ShopifyCli::IdentityAuth::IDENTITY_ACCESS_TOKENS.all? { |key| ShopifyCli::DB.exists?(key) }
      end
    end
  end
end
