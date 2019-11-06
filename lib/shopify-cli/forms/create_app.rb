require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class CreateApp < Form
      positional_arguments :name
      flag_arguments :title, :type, :organization_id, :shop_domain

      def ask
        self.title ||= fallback_title
        self.type = ask_type
        self.organization_id ||= organization["id"].to_i
        self.shop_domain ||= ask_shop_domain
      end

      private

      def fallback_title
        name.gsub(/(.)([A-Z])/, '\1 \2') # change camelcase to title
          .gsub(/(-|_)/, ' ') # change snakecase to title
          .capitalize
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

      def organizations
        @organizations ||= Helpers::Organizations.fetch_all(ctx)
      end

      def organization
        @organiztion ||= if !organization_id.nil?
          org = Helpers::Organizations.fetch(ctx, id: organization_id)
          raise(ShopifyCli::Abort, 'Cannot find an organization with that ID') if org.nil?
          org
        elsif organizations.count == 0
          ctx.puts('Please visit https://partners.shopify.com/ to create a partners account')
          raise(ShopifyCli::Abort, 'No organizations available.')
        elsif organizations.count == 1
          ctx.puts("Organization {{green:#{organizations.first['businessName']}}}")
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask('Which organization do you want this app to belong to?') do |handler|
            organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def ask_shop_domain
        if organization['stores'].count == 0
          ctx.puts('No developement shops available.')
          ctx.puts("Visit {{green:https://partners.shopify.com/#{organization['id']}/stores}} to create one")
        elsif organization['stores'].count == 1
          domain = organization['stores'].first['shopDomain']
          ctx.puts("Using development shop {{green:#{domain}}}")
          domain
        else
          CLI::UI::Prompt.ask(
            'Which development store would you like to work with?',
            options: organization["stores"].map { |s| s["shopDomain"] }
          )
        end
      end
    end
  end
end
