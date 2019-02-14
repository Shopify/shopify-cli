require 'shopify_cli'

module ShopifyCli
  module AppTypes
    class Node < ShopifyCli::Task
      class << self
        def description
          'node embedded app'
        end

        def callback_url(host)
          "#{host}/auth/callback"
        end

        def keys(key, secret, host)
          <<~KEYS
            SHOPIFY_API_KEY=#{key}
            SHOPIFY_API_SECRET_KEY=#{secret}
            SHOPIFY_DOMAIN=myshopify.io
            HOST=#{host}
          KEYS
        end
      end

      def call(*args)
        @name = args.shift
        @ctx = args.shift
        @dir = File.join(Dir.pwd, @name)
        embedded_app
      end

      protected

      def embedded_app
        ShopifyCli::Tasks::Clone.call('git@github.com:shopify/webgen-embeddedapp.git', @name)
        ShopifyCli::Finalize.request_cd(@name)
        ShopifyCli::Tasks::JsDeps.call(@dir)
        puts CLI::UI.fmt("{{yellow:*}} writing .env file")
        @keys = Helpers::KeysHelper.new(self, @ctx)
        @keys.write(File.join(@name, '.env'))
        remove_git_dir
        puts CLI::UI.fmt(post_clone)
      end

      def remove_git_dir
        git_dir = File.join(Dir.pwd, @name, '.git')
        if File.exist?(git_dir)
          FileUtils.rm_r(git_dir)
        end
      end

      def post_clone
        "Run {{command:npm run dev}} to start the app server"
      end
    end
  end
end
