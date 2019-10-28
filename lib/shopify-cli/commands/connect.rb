require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::Command

      def call(*)
        if Project.at(Dir.pwd)
          @ctx.puts "{{yellow:! Don't use}} {{cyan:connect}} {{yellow:for production apps}}"
          org_id = get_organization
          app = get_app(org_id)
          shop = get_shop
          write_env(app, shop)
          @ctx.puts "{{v}} Project now connected to {{green:app_name}}"
          @ctx.puts "{{*}} Run {{cyan:shopify serve}} to start a local development server"
        end
      end

      def get_organization
        orgs = Helpers::Organizations.fetch_all(@ctx)
        if orgs.count == 1
          orgs.first
        else
          org_id = CLI::UI::Prompt.ask('Which organization does this app belong to?') do |handler|
            orgs.each { |org| handler.option(org["businessName"]) { org["id"] } }
          end
          orgs.find { |org| org["id"] == org_id }
        end
        org_id
      end

      def get_app(org_id)
       @org = Helpers::Organizations.fetch(@ctx, id: org_id)
        apps = @org['apps']['nodes']
        app = CLI::UI::Prompt.ask('Which app does this project belong to?') do |handler|
          apps.each { |app| handler.option(app["title"]) {app} }
        end
        app
      end

      def get_shop
        if @org['stores'].count == 1
         @org.first
        elsif @org['stores'].count === 0
          @ctx.puts('No developement shops available.')
          @ctx.puts("Visit https://partners.shopify.com/#{@org_id}/stores to create one") 
        else
          shop = CLI::UI::Prompt.ask('Which development store would you like to use?') do |handler|
            @org['stores'].each{ |store| handler.option(store["shopName"]) {store["shopDomain"]}}
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
