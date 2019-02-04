require 'shopify-cli'

module ShopifyCli
  module AppTypes
    class Node < ShopifyCli::Task
      def call(*args)
        @name = args.shift
        @dir = File.join(Dir.pwd, @name)
        embedded_app
      end

      def self.description
        'node embedded app'
      end

      protected

      def embedded_app
        ShopifyCli::Tasks::Clone.call('git@github.com:shopify/webgen-embeddedapp.git', @name)
        ShopifyCli::Finalize.request_cd(@name)
        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')
        write_env_file(api_key, api_secret)
        ShopifyCli::Tasks::JsDeps.call(@dir)
        puts CLI::UI.fmt(post_clone)
      end

      def write_env_file(api_key, api_secret)
        File.write(File.join(@name, '.env'),
          "SHOPIFY_API_KEY=#{api_key}\nSHOPIFY_API_SECRET_KEY=#{api_secret}")
      end

      def post_clone
        "Run {{command:shopify server}} to start the app server"
      end
    end
  end
end
