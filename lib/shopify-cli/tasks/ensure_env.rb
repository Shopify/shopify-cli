require 'shopify_cli'

module ShopifyCli
  module Tasks
    class EnsureEnv < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        Resources::EnvFile.read(ctx.root)
      rescue Errno::ENOENT
        ask
      end

      def ask
        api_key = CLI::UI.ask(@ctx.message('core.tasks.ensure_env.api_key_question'))
        api_secret = CLI::UI.ask(@ctx.message('core.tasks.ensure_env.api_secret_key_question'))
        shop = CLI::UI.ask(@ctx.message('core.tasks.ensure_env.development_store_question'))

        shop.gsub!(/https?\:\/\//, '')

        env = Resources::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          shop: shop,
          host: ShopifyCli::Tunnel.start(@ctx),
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)
        env
      end
    end
  end
end
