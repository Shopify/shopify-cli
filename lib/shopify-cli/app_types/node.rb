require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < AppType
      class << self
        def env_file(key, secret, host)
          <<~KEYS
            SHOPIFY_API_KEY=#{key}
            SHOPIFY_API_SECRET_KEY=#{secret}
            SHOPIFY_DOMAIN=myshopify.io
            HOST=#{host}
          KEYS
        end
      end

      def self.description
        'node embedded app'
      end

      def self.serve_command
        'npm run dev'
      end

      def self.generate
        {
          page: 'npm run-script generate-page'
        }
      end

      protected

      def build
        ShopifyCli::Tasks::Clone.call('git@github.com:shopify/webgen-embeddedapp.git', @name)
        ShopifyCli::Finalize.request_cd(@name)
        ShopifyCli::Tasks::JsDeps.call(@dir)

        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')

        # temporary metadata construction, will be replaced by data from Partners
        @ctx.app_metadata = {
          apiKey: api_key,
          sharedSecret: api_secret,
          host: 'host', # to be added with ngrok task
        }

        @keys = Helpers::EnvFileHelper.new(self, @ctx)
        @keys.write('.env')
        puts CLI::UI.fmt(post_clone)
      end

      def post_clone
        "Run {{command:npm run dev}} to start the app server"
      end
    end
  end
end
