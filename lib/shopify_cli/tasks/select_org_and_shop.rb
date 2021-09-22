require "shopify_cli"

module ShopifyCLI
  module Tasks
    class SelectOrgAndShop < ShopifyCLI::Task
      attr_reader :ctx

      def call(ctx, organization_id: nil, shop_domain: nil)
        @ctx = ctx
        return response(organization_id.to_i, shop_domain) unless organization_id.nil? || shop_domain.nil?
        org = get_organization(organization_id)
        unless Shopifolk.acting_as_shopify_organization?
          shop_domain ||= get_shop_domain(org)
        end
        ShopifyCLI::Core::Monorail.metadata[:organization_id] = org["id"].to_i
        response(org["id"].to_i, shop_domain)
      end

      private

      def response(organization_id, shop_domain)
        result = { organization_id: organization_id }
        result[:shop_domain] = shop_domain if shop_domain
        result
      end

      def organizations
        @organizations ||= ShopifyCLI::PartnersAPI::Organizations.fetch_all(ctx)
      end

      def get_organization(organization_id)
        @organization ||= if !organization_id.nil?
          org = ShopifyCLI::PartnersAPI::Organizations.fetch(ctx, id: organization_id)
          if org.nil?
            ctx.puts(ctx.message("core.tasks.select_org_and_shop.authentication_issue", ShopifyCLI::TOOL_NAME))
            ctx.abort(ctx.message("core.tasks.select_org_and_shop.error.organization_not_found"))
          end
          org
        elsif organizations.count == 0
          if Shopifolk.acting_as_shopify_organization?
            ctx.abort(ctx.message("core.tasks.select_org_and_shop.error.shopifolk_notice", ShopifyCLI::TOOL_NAME))
          else
            ctx.abort(ctx.message("core.tasks.select_org_and_shop.error.no_organizations"))
          end
        elsif organizations.count == 1
          org = organizations.first
          ctx.puts(ctx.message("core.tasks.select_org_and_shop.organization", org["businessName"], org["id"]))
          org
        else
          org_id = CLI::UI::Prompt.ask(ctx.message("core.tasks.select_org_and_shop.organization_select")) do |handler|
            organizations.each do |o|
              handler.option(ctx.message("core.partners_api.org_name_and_id", o["businessName"], o["id"])) { o["id"] }
            end
          end
          organizations.find { |o| o["id"] == org_id }
        end
      end

      def get_shop_domain(organization)
        valid_stores = organization["stores"].select do |store|
          store["transferDisabled"] == true || store["convertableToPartnerTest"] == true
        end

        if valid_stores.count == 0
          ctx.puts(ctx.message("core.tasks.select_org_and_shop.error.no_development_stores"))
          ctx.puts(ctx.message("core.tasks.select_org_and_shop.create_store", organization["id"]))
          ctx.puts(ctx.message("core.tasks.select_org_and_shop.authentication_issue", ShopifyCLI::TOOL_NAME))
        elsif valid_stores.count == 1
          domain = valid_stores.first["shopDomain"]
          ctx.puts(ctx.message("core.tasks.select_org_and_shop.development_store", domain))
          domain
        else
          CLI::UI::Prompt.ask(
            ctx.message("core.tasks.select_org_and_shop.development_store_select"),
            options: valid_stores.map { |s| s["shopDomain"] }
          )
        end
      end
    end
  end
end
