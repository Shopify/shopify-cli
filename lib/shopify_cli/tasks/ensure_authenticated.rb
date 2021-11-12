require "shopify_cli"

module ShopifyCLI
  module Tasks
    class EnsureAuthenticated < ShopifyCLI::Task
      def call(ctx)
        return if ShopifyCLI::Environment.acceptance_test?
        unless ShopifyCLI::IdentityAuth.authenticated?
          raise ShopifyCLI::Abort,
            ctx.message("core.identity_auth.token_authentication", ShopifyCLI::EnvironmentVariables::AUTH_TOKEN)
        end
        if ShopifyCLI::IdentityAuth.environment_auth_token?
          ctx.puts(ctx.message("core.identity_auth"))
        end
      end
    end
  end
end
