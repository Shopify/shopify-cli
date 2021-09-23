require "shopify_cli"

module ShopifyCLI
  module Tasks
    class EnsureAuthenticated < ShopifyCLI::Task
      def call(ctx)
        ctx.abort(
          ctx.message("core.identity_auth.login_prompt", ShopifyCLI::TOOL_NAME)
        ) unless ShopifyCLI::IdentityAuth::IDENTITY_ACCESS_TOKENS.all? { |key| ShopifyCLI::DB.exists?(key) }
      end
    end
  end
end
