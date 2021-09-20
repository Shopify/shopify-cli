require "shopify_cli"

module ShopifyCli
  module Tasks
    class ConfirmStore < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        store = ShopifyCli::AdminAPI.get_shop_or_abort(ctx)
        if CLI::UI::Prompt.confirm(ctx.message("core.tasks.confirm_store.prompt", store), default: false)
          ctx.puts(ctx.message("core.tasks.confirm_store.confirmation", store))
        else
          ctx.puts(ctx.message("core.tasks.confirm_store.cancelling"))
          raise AbortSilent
        end
      end
    end
  end
end
