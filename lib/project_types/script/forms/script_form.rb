# frozen_string_literal: true

module Script
  module Forms
    class ScriptForm < ShopifyCli::Form
      protected

      def organization
        @organization ||= ask_organization(ctx)
      end

      def organizations
        return @organizations if defined?(@organizations)
        UI::StrictSpinner.spin(ctx.message('script.forms.script_form.fetching_organizations')) do |spinner|
          @organizations = ShopifyCli::PartnersAPI::Organizations.fetch_with_app(ctx)
          spinner.update_title(ctx.message('script.forms.script_form.fetched_organizations'))
        end
        @organizations
      end

      def ask_app_api_key(apps, message: ctx.message('script.forms.script_form.ask_app_api_key_default'))
        if apps.count == 0
          raise Errors::NoExistingAppsError
        elsif apps.count == 1
          ctx.puts(ctx.message(
            'script.forms.script_form.using_app',
            title: apps.first['title'],
            api_key: apps.first['apiKey']
          ))
          apps.first["apiKey"]
        else
          CLI::UI::Prompt.ask(message) do |handler|
            apps.each { |app| handler.option(app["title"]) { app["apiKey"] } }
          end
        end
      end

      def ask_organization(ctx)
        if organizations.count == 0
          raise Errors::NoExistingOrganizationsError
        elsif organizations.count == 1
          ctx.puts(ctx.message('script.forms.script_form.using_organization', organizations.first['businessName']))
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask(ctx.message('script.forms.script_form.select_organization')) do |handler|
            organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def ask_shop_domain(ctx, organization, message: 'Select a development store')
        if organization['stores'].count == 0
          raise Errors::NoExistingStoresError, organization['id']
        elsif organization['stores'].count == 1
          domain = organization['stores'].first['shopDomain']
          ctx.puts("Using development store {{green:#{domain}}}")
          domain
        else
          CLI::UI::Prompt.ask(message, options: organization["stores"].map { |s| s["shopDomain"] })
        end
      end
    end
  end
end
