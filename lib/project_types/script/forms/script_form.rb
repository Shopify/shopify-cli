# frozen_string_literal: true

module Script
  module Forms
    class ScriptForm < ShopifyCli::Form
      protected

      def organization(api_key = nil)
        @organization ||= ask_organization(api_key)
      end

      def organizations
        return @organizations if defined?(@organizations)
        ctx.puts(ctx.message('script.forms.script_form.fetching_organizations'))
        @organizations = ShopifyCli::PartnersAPI::Organizations.fetch_with_app(ctx)
      end

      def ask_app(apps, api_key = nil, message: ctx.message('script.forms.script_form.ask_app_default'))
        unless api_key.nil?
          corresponding_app = apps.select { |app| app["apiKey"] == api_key }
          return corresponding_app unless corresponding_app.empty?
        end

        if apps.count == 0
          raise Errors::NoExistingAppsError
        elsif apps.count == 1
          ctx.puts(ctx.message(
            'script.forms.script_form.using_app',
            title: apps.first['title'],
            api_key: apps.first['apiKey']
          ))
          apps.first
        else
          CLI::UI::Prompt.ask(message) do |handler|
            apps.each { |app| handler.option(app["title"]) { app } }
          end
        end
      end

      def ask_organization(api_key = nil)
        unless api_key.nil?
          org = organizations.find { |ogz| ogz['apps'].select { |app| app["apiKey"] == api_key } }
          return org unless org.empty?
        end

        if organizations.count == 0
          raise Errors::NoExistingOrganizationsError
        elsif organizations.count == 1
          org = organizations.first
          ctx.puts(ctx.message('script.forms.script_form.using_organization',
            ctx.message('core.partners_api.org_name_and_id', org['businessName'], org['id'])))
          org
        else
          org_id = CLI::UI::Prompt.ask(ctx.message('script.forms.script_form.select_organization')) do |handler|
            organizations.each do |o|
              handler.option(ctx.message('core.partners_api.org_name_and_id', o['businessName'], o['id'])) { o['id'] }
            end
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def ask_shop_domain(organization, message: ctx.message('script.forms.script_form.ask_shop_domain_default'))
        if organization['stores'].count == 0
          raise Errors::NoExistingStoresError, organization['id']
        elsif organization['stores'].count == 1
          domain = organization['stores'].first['shopDomain']
          ctx.puts(ctx.message('script.forms.script_form.using_development_store', domain: domain))
          domain
        else
          CLI::UI::Prompt.ask(message, options: organization["stores"].map { |s| s["shopDomain"] })
        end
      end

      def write_env(org, api_key, secret_key, shop)
        ShopifyCli::Resources::EnvFile.new(
          api_key: api_key,
          secret: secret_key,
          shop: shop,
          org: org
        ).write(@ctx)
      end
    end
  end
end
