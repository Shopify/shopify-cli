require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def env_file
          <<~KEYS
            SHOPIFY_API_KEY={api_key}
            SHOPIFY_API_SECRET_KEY={secret}
            HOST={host}
            SHOP={shop}
            SCOPES={scopes}
          KEYS
        end
      end

      def self.description
        'node embedded app'
      end

      def self.serve_command(ctx)
        %W(
          HOST=#{ctx.app_metadata[:host]}
          PORT=#{ShopifyCli::Tasks::Tunnel::PORT}
          npm run dev
        ).join(' ')
      end

      def self.generate
        {
          page: 'npm run-script generate-page',
          billing_recurring: 'npm run-script generate-recurring-billing',
          billing_one_time: 'npm run-script generate-one-time-billing',
        }
      end

      def build
        ShopifyCli::Tasks::Clone.call('git@github.com:shopify/webgen-embeddedapp.git', name)
        ShopifyCli::Finalize.request_cd(name)
        ShopifyCli::Tasks::JsDeps.call(ctx.root)

        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')

        env_file = Helpers::EnvFile.new(
          app_type: self,
          api_key: api_key,
          secret: api_secret,
          host: ctx.app_metadata[:host],
          scopes: 'read_products',
        )
        env_file.write(ctx, '.env')

        ctx.rm_r(File.join(ctx.root, '.git'))
        ctx.rm_r(File.join(ctx.root, '.github'))

        puts CLI::UI.fmt(post_clone)
      end

      def post_clone
        "Run {{command:npm run dev}} to start the app server"
      end
    end
  end
end
