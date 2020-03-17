require 'uri'

module Rails
  module Forms
    class Create < ShopifyCli::Form
      attr_accessor :name
      flag_arguments :title, :organization_id, :shop_domain

      def ask
        self.title ||= CLI::UI::Prompt.ask('App Name')
        self.name = self.title.downcase.split(" ").join("_")
        self.organization_id ||= organization["id"].to_i
        self.shop_domain ||= ask_shop_domain
      end

      private

      def organizations
        @organizations ||= ShopifyCli::Helpers::Organizations.fetch_all(ctx)
      end

      def organization
        @organization ||= if !organization_id.nil?
          org = ShopifyCli::Helpers::Organizations.fetch(ctx, id: organization_id)
          ctx.error('Cannot find an organization with that ID') if org.nil?
          org
        elsif organizations.count == 0
          ctx.puts('Please visit https://partners.shopify.com/ to create a partners account')
          ctx.error('No organizations available.')
        elsif organizations.count == 1
          ctx.puts("Organization {{green:#{organizations.first['businessName']}}}")
          organizations.first
        else
          org_id = CLI::UI::Prompt.ask('Select organization') do |handler|
            organizations.each { |o| handler.option(o['businessName']) { o['id'] } }
          end
          organizations.find { |o| o['id'] == org_id }
        end
      end

      def ask_shop_domain
        if organization['stores'].count == 0
          ctx.puts('{{x}} No Development Stores available.')
          ctx.puts("Visit {{underline:https://partners.shopify.com/#{organization['id']}/stores}} to create one")
        elsif organization['stores'].count == 1
          domain = organization['stores'].first['shopDomain']
          ctx.puts("Using Development Store {{green:#{domain}}}")
          domain
        else
          CLI::UI::Prompt.ask(
            'Select a Development Store',
            options: organization["stores"].map { |s| s["shopDomain"] }
          )
        end
      end
    end
  end
end

