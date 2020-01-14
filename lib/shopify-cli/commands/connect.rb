require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::ContextualCommand
      available_in :app

      def call(*)
        if Project.at(Dir.pwd)
          @ctx.puts "{{yellow:! Don't use}} {{cyan:connect}} {{yellow:for production apps}}"
          org = fetch_org
          id = org['id']
          app = get_app(org['apps'])
          shop = get_shop(org['stores'], id)
          write_env(app, shop)
          @ctx.puts "{{v}} Project now connected to {{green:#{app.first['title']}}}"
          @ctx.puts "{{*}} Run {{cyan:shopify serve}} to start a local development server"
        end
      end

      def fetch_org
        orgs = Helpers::Organizations.fetch_with_app(@ctx)
        org_id = if orgs.count == 1
          orgs.first["id"]
        else
          CLI::UI::Prompt.ask('Which organization does this project belong to?') do |handler|
            orgs.each { |org| handler.option(org["businessName"]) { org["id"] } }
          end
        end
        org = orgs.find { |o| o["id"] == org_id }
        org
      end

      def get_app(apps)
        app_id = if apps.count == 1
          apps.first["id"]
        else
          CLI::UI::Prompt.ask('Which app does this project belong to?') do |handler|
            apps.each { |app| handler.option(app["title"]) { app["id"] } }
          end
        end
        apps.select { |app| app["id"] == app_id }
      end

      def get_shop(shops, id)
        if shops.count == 1
          shops.first
        elsif shops.count == 0
          @ctx.puts('No developement shops available.')
          @ctx.puts("Visit {{underline:https://partners.shopify.com/#{id}/stores}} to create one")
        else
          shop = CLI::UI::Prompt.ask('Which development store would you like to use?') do |handler|
            shops.each { |s| handler.option(s["shopName"]) { s["shopDomain"] } }
          end
        end
        shop
      end

      def write_env(app, shop)
        Helpers::EnvFile.new(
          api_key: app.first["apiKey"],
          secret: app.first["apiSecretKeys"].first["secret"],
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
