require 'shopify-cli'

module ShopifyCli
  module AppTypes
    class Node < ShopifyCli::Task
      def call(*args)
        @name = args.shift
        embedded_app
      end

      def self.description
        'node embedded app'
      end

      protected

      def embedded_app
        ShopifyCli::Tasks::Clone.call('git@github.com:shopify/webgen-embeddedapp.git', @name)
        api_key = CLI::UI.ask('What is your Shopify API Key')
        api_secret = CLI::UI.ask('What is your Shopify API Secret')
        write_env_file(api_key, api_secret)

        CLI::UI::Frame.open('Installing dependencies...') do
          yarn
        end
        puts CLI::UI.fmt(post_clone)
        ShopifyCli::Finalize.request_cd(@name)
      end

      def write_env_file(api_key, api_secret)
        File.write(File.join(@name, '.env'),
          "SHOPIFY_API_KEY=#{api_key}\nSHOPIFY_API_SECRET_KEY=#{api_secret}")
      end

      def post_clone
        "Run {{command:shopify server}} to start the app server"
      end

      def yarn
        CLI::UI::Progress.progress do |bar|
          success = CLI::Kit::System.system('npm install', chdir: @name) do |_out, err|
            match = err.match(/(\d+)\/(\d+)/)
            next unless match
            percent = (match[1] / match[2] * 100).round(2)
            bar.tick(set_percent: percent)
          end.success?
          return false unless success
          bar.tick(set_percent: 1.0)
          true
        end
      end
    end
  end
end
