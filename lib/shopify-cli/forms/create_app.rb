require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class CreateApp < Form
      positional_arguments :name
      flag_arguments :title, :type, :app_url, :organization_id, :shop_domain

      def ask
        self.title ||= fallback_title
        self.type = ask_type
        self.app_url = ask_app_url
        self.organization_id ||= organization["id"].to_i
        self.shop_domain ||= ask_shop_domain
      end

      private

      def fallback_title
        name.gsub(/(.)([A-Z])/, '\1 \2') # change camelcase to title
          .gsub(/(-|_)/, ' ') # change snakecase to title
          .capitalize
      end

      def ask_app_url
        while app_url !~ /\A#{URI::DEFAULT_PARSER.regexp[:ABS_URI]}\z/
          ctx.puts('Invalid URL') unless app_url.nil?
          self.app_url = CLI::UI::Prompt.ask('What is your Application URL?')
        end
        app_url
      end

      def ask_type
        return type unless AppTypeRegistry[type.to_s.to_sym].nil?
        ctx.puts('Invalid App Type.') unless type.nil?
        CLI::UI::Prompt.ask('What type of app project would you like to create?') do |handler|
          AppTypeRegistry.each do |identifier, type|
            handler.option(type.description) { identifier }
          end
        end
      end

      def organization
        @organiztion ||= begin
          if organization_id.nil?
            orgs = Helpers::Organizations.fetch_all(ctx)
            if orgs.count == 0
              ctx.puts('Please visit https://partners.shopify.com/ to create a partners account')
              raise(ShopifyCli::Abort, 'No organizations available.')
            elsif orgs.count == 1
              orgs.first
            else
              org_id = CLI::UI::Prompt.ask('Which organization do you want this app to belong to?') do |handler|
                orgs.each { |org| handler.option(org["businessName"]) { org["id"] } }
              end
              orgs.find { |org| org["id"] == org_id }
            end
          else
            org = Helpers::Organizations.fetch(ctx, id: organization_id)
            raise(ShopifyCli::Abort, "Cannot find an organization with that ID") if org.nil?
            org
          end
        end
      end

      def ask_shop_domain
        if organization['stores'].count == 0
          ctx.puts('No developement shops available.')
          ctx.puts("Visit https://partners.shopify.com/#{organization['id']}/stores to create one")
          return ""
        end
        return organization['stores'].first['shopDomain'] if organization['stores'].count == 1
        CLI::UI::Prompt.ask(
          'Which development store would you like to work with?',
          options: organization["stores"].map { |s| s["shopDomain"] }
        )
      end
    end
  end
end
