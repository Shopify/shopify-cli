require "shopify_cli"

module ShopifyCLI
  module Tasks
    class EnsureEnv < ShopifyCLI::Task
      def call(ctx, regenerate: false, required: [:api_key, :secret])
        @ctx = ctx
        env_data =
          begin
            Resources::EnvFile.parse_external_env
          rescue Errno::ENOENT
            {}
          end

        return {} if !regenerate && required.all? { |property| env_data[property] }

        org = fetch_org
        write_env(env_data, org)
        org
      end

      private

      def fetch_org
        if Shopifolk.check && wants_to_run_against_shopify_org?
          Shopifolk.act_as_shopify_organization
        end
        orgs = PartnersAPI::Organizations.fetch_all_with_apps(@ctx)
        org_id = if orgs.count == 1
          orgs.first["id"]
        else
          CLI::UI::Prompt.ask(@ctx.message("core.tasks.ensure_env.organization_select")) do |handler|
            orgs.each do |org|
              handler.option(
                @ctx.message("core.partners_api.org_name_and_id", org["businessName"], org["id"])
              ) { org["id"] }
            end
          end
        end
        orgs.find { |o| o["id"] == org_id }
      end

      def get_app(org_id, apps)
        if apps.count == 1
          apps.first
        elsif apps.count == 0
          @ctx.puts(@ctx.message("core.tasks.ensure_env.no_apps"))
          title = CLI::UI::Prompt.ask(@ctx.message("core.tasks.ensure_env.app_name"))
          type = CLI::UI::Prompt.ask(@ctx.message("core.tasks.ensure_env.app_type.select")) do |handler|
            handler.option(@ctx.message("core.tasks.ensure_env.app_type.select_public")) { "public" }
            handler.option(@ctx.message("core.tasks.ensure_env.app_type.select_custom")) { "custom" }
          end
          ShopifyCLI::Tasks::CreateApiClient.call(@ctx, org_id: org_id, title: title, type: type)
        else
          CLI::UI::Prompt.ask(@ctx.message("core.tasks.ensure_env.app_select")) do |handler|
            apps.each { |app| handler.option(app["title"]) { app } }
          end
        end
      end

      def get_shop(shops, id)
        if shops.count == 1
          shop = shops.first["shopDomain"]
        elsif shops.count == 0
          @ctx.puts(@ctx.message("core.tasks.ensure_env.no_development_stores", id))
        else
          shop = CLI::UI::Prompt.ask(@ctx.message("core.tasks.ensure_env.development_store_select")) do |handler|
            shops.each { |s| handler.option(s["shopName"]) { s["shopDomain"] } }
          end
        end
        shop
      end

      def write_env(env_data, org)
        id = org["id"]
        app = get_app(id, org["apps"])

        env_data[:shop] = get_shop(org["stores"], id)
        env_data[:api_key] = app["apiKey"]
        env_data[:secret] = app["apiSecretKeys"].first["secret"]
        env_data[:scopes] = "write_products,write_customers,write_draft_orders" if env_data[:scopes].nil?
        env_data[:extra] = {} if env_data[:extra].nil?

        Resources::EnvFile.new(
          env_data
        ).write(@ctx)
      end
    end
  end
end
