require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create
      class Project < ShopifyCli::Command
        def call(args, _name)
          if args.empty?
            @ctx.puts(self.class.help)
            return
          end
          name = args.first
          ShopifyCli::Tasks::Tunnel.call(@ctx)

          app_type = CLI::UI::Prompt.ask('What type of app project would you like to create?') do |handler|
            AppTypeRegistry.each do |identifier, type|
              handler.option(type.description) { identifier }
            end
          end

          AppTypeRegistry.check_dependencies(app_type, @ctx)
          ask_for_credentials

          AppTypeRegistry.build(app_type, name, @ctx)
          ShopifyCli::Project.write(@ctx, app_type)
        end

        def ask_for_credentials
          api_key = CLI::UI.ask('What is your Shopify API key?')
          api_secret = CLI::UI.ask('What is your Shopify API secret key?')
          shop = CLI::UI.ask('What is your development store address? (e.g. my-test-shop.myshopify.com)')

          shop.gsub!(/https?\:\/\//, '')

          @ctx.app_metadata = {
            api_key: api_key,
            secret: api_secret,
            shop: shop,
          }
        end

        def self.help
          <<~HELP
            Create a new app project.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}
        HELP
        end
      end
    end
  end
end
