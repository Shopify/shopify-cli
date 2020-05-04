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
        UI::StrictSpinner.spin('Fetching organizations') do |spinner|
          @organizations = ShopifyCli::PartnersAPI::Organizations.fetch_with_app(ctx)
          spinner.update_title('Fetched organizations')
        end
        @organizations
      end

      def ask_app_api_key(ctx, apps, message: 'Which app do you want this script to belong to?')
        if apps.count == 0
          raise Errors::NoExistingAppsError
        elsif apps.count == 1
          ctx.puts("Using app {{green:#{apps.first['title']} (#{apps.first['apiKey']})}}.")
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
          ctx.puts("Organization {{green:#{organizations.first['businessName']}}}.")
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask('Select organization.') do |handler|
            organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end
    end
  end
end
