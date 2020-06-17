require 'shopify_cli'

module ShopifyCli
  module Commands
    class Connect < ShopifyCli::Command
      def call(*)
        if Project.current
          @ctx.puts @ctx.message('core.connect.production_warning')
          org = fetch_org
          id = org['id']
          app = get_app(org['apps'])
          shop = get_shop(org['stores'], id)
          write_env(app, shop)
          @ctx.puts(@ctx.message('core.connect.connected', app.first['title']))
          @ctx.puts(@ctx.message('core.connect.serve', ShopifyCli::TOOL_NAME))
        end
      end

      def fetch_org
        orgs = PartnersAPI::Organizations.fetch_with_app(@ctx)
        org_id = if orgs.count == 1
          orgs.first["id"]
        else
          CLI::UI::Prompt.ask(@ctx.message('core.connect.organization_select')) do |handler|
            orgs.each do |org|
              handler.option(
                ctx.message('core.partners_api.org_name_and_id', org['businessName'], org['id'])
              ) { org["id"] }
            end
          end
        end
        org = orgs.find { |o| o["id"] == org_id }
        org
      end

      def get_app(apps)
        app_id = if apps.count == 1
          apps.first["id"]
        else
          CLI::UI::Prompt.ask(@ctx.message('core.connect.app_select')) do |handler|
            apps.each { |app| handler.option(app["title"]) { app["id"] } }
          end
        end
        apps.select { |app| app["id"] == app_id }
      end

      def get_shop(shops, id)
        if shops.count == 1
          shop = shops.first["shopDomain"]
        elsif shops.count == 0
          @ctx.puts(@ctx.message('core.connect.no_development_stores', id))
        else
          shop = CLI::UI::Prompt.ask(@ctx.message('core.connect.development_store_select')) do |handler|
            shops.each { |s| handler.option(s["shopName"]) { s["shopDomain"] } }
          end
        end
        shop
      end

      def write_env(app, shop)
        Resources::EnvFile.new(
          api_key: app.first["apiKey"],
          secret: app.first["apiSecretKeys"].first["secret"],
          shop: shop,
          scopes: 'write_products,write_customers,write_draft_orders',
        ).write(@ctx)
      end

      def self.help
        ShopifyCli::Context.message('core.connect.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
