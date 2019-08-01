require 'shopify_cli'

module ShopifyCli
  module Tasks
    class EnsureEnv < ShopifyCli::Task
      def call(ctx)
        @ctx = ctx
        Helpers::EnvFile.read(ctx.root)
      rescue Errno::ENOENT
        ask
      end

      def ask
        api_key = CLI::UI.ask('What is your Shopify API key?')
        api_secret = CLI::UI.ask('What is your Shopify API secret key?')
        shop = CLI::UI.ask('What is your development store URL? (e.g. my-test-shop.myshopify.com)')

        shop.gsub!(/https?\:\/\//, '')

        env = Helpers::EnvFile.new(
          api_key: api_key,
          secret: api_secret,
          shop: shop,
          host: Tasks::Tunnel.call(@ctx),
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)
        env
      end
    end
  end
end
