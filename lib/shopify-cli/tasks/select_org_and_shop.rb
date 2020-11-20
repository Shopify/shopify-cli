require 'shopify_cli'

module ShopifyCli
  module Tasks
    class SelectOrgAndShop < ShopifyCli::Task
      attr_reader :ctx

      def call(ctx, organization_id: nil, shop_domain: nil)
        @ctx = ctx
        return response(organization_id.to_i, shop_domain) unless organization_id.nil? || shop_domain.nil?
        if Shopifolk.check && wants_to_run_against_shopify_org?
          Shopifolk.act_as_shopify_organization
        end
        org = get_organization(organization_id)
        shop_domain ||= get_shop_domain(org)
        ShopifyCli::Core::Monorail.metadata[:organization_id] = org["id"].to_i
        response(org["id"].to_i, shop_domain)
      end

      private

      def response(organization_id, shop_domain)
        {
          organization_id: organization_id,
          shop_domain: shop_domain,
        }
      end

      def organizations
        @organizations ||= ShopifyCli::PartnersAPI::Organizations.fetch_all(ctx)
      end

      def get_organization(organization_id)
        @organization ||= if !organization_id.nil?
          org = ShopifyCli::PartnersAPI::Organizations.fetch(ctx, id: organization_id)
          if org.nil?
            ctx.puts(ctx.message('core.tasks.select_org_and_shop.error.authentication_issue', ShopifyCli::TOOL_NAME))
            ctx.abort(ctx.message('core.tasks.select_org_and_shop.error.organization_not_found'))
          end
          org
        elsif organizations.count == 0
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.error.partners_notice'))
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.authentication_issue', ShopifyCli::TOOL_NAME))
          ctx.abort(ctx.message('core.tasks.select_org_and_shop.error.no_organizations'))
        elsif organizations.count == 1
          org = organizations.first
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.organization', org['businessName'], org['id']))
          org
        else
          org_id = CLI::UI::Prompt.ask(ctx.message('core.tasks.select_org_and_shop.organization_select')) do |handler|
            organizations.each do |o|
              handler.option(ctx.message('core.partners_api.org_name_and_id', o['businessName'], o['id'])) { o['id'] }
            end
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def get_shop_domain(organization)
        valid_stores = organization['stores'].select do |store|
          store['transferDisabled'] == true || store['convertableToPartnerTest'] == true
        end

        if valid_stores.count == 0
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.error.no_development_stores'))
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.create_store', organization['id']))
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.authentication_issue', ShopifyCli::TOOL_NAME))
        elsif valid_stores.count == 1
          domain = valid_stores.first['shopDomain']
          ctx.puts(ctx.message('core.tasks.select_org_and_shop.development_store', domain))
          domain
        else
          CLI::UI::Prompt.ask(
            ctx.message('core.tasks.select_org_and_shop.development_store_select'),
            options: valid_stores.map { |s| s['shopDomain'] }
          )
        end
      end
    end
  end
end
