require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::Command

      def call(*)
        if Project.at(Dir.pwd)
          @ctx.puts "{{yellow:! Don't use}} {{cyan:connect}} {{yellow:for production apps}}"
          org = get_organization
          id = org['id']
          app = get_app(org['apps'])
          shop = get_shop(org['stores'], id)
          write_env(app, shop)
          @ctx.puts "{{v}} Project now connected to {{green:app_name}}"
          @ctx.puts "{{*}} Run {{cyan:shopify serve}} to start a local development server"
        end
      end

      def get_organization
        orgs = Helpers::Organizations.fetch_with_app(@ctx)
        org = if orgs.count == 1
          orgs.first
        else
         CLI::UI::Prompt.ask('Which organization does this app belong to?') do |handler|
            orgs.each { |org| handler.option(org["businessName"]) { org } }
          end
        end
        org
      end

      def get_app(apps)
        app = CLI::UI::Prompt.ask('Which app does this project belong to?') do |handler|
          apps.each { |app| handler.option(app["title"]) {app} }
        end
        app
      end

      def get_shop(shops, id)
        if shops.count == 1
         shops.first
        elsif shops.count === 0
          @ctx.puts('No developement shops available.')
          @ctx.puts("Visit https://partners.shopify.com/#{id}/stores to create one")
        else
          shop = CLI::UI::Prompt.ask('Which development store would you like to use?') do |handler|
            shops.each{ |shop| handler.option(shop["shopName"]) {shop["shopDomain"]}}
          end
        end
        shop
      end

      def write_env(app, shop)
        Helpers::EnvFile.new(
          api_key: app["apiKey"],
          secret: app["apiSecretKeys"].first["secret"],
          shop: shop,
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)
      end

      def self.help
        <<~HELP
          Connect a Shopify-App-Cli project. Restores the ENV file
            Usage: {{command:#{ShopifyCli::TOOL_NAME} connect}}
        HELP
      end

      def self.extended_help
        <<~HELP
          Connect a Shopify-App-Cli project. Restores the Env file
          Usage: {{command:#{ShopifyCli::TOOL_NAME} connect}}
        HELP
      end
    end
  end
end
