# frozen_string_literal: true

module Extension
  module Forms
    class Create < ShopifyCli::Form
      flag_arguments :title, :type, :api_key

      attr_reader :app

      ExtensionType = Struct.new(:identifier, :description, keyword_init: true) do
        def ==(extensionType)
          case extensionType
          when String
            self.identifier == extensionType
          else
            super(extensionType)
          end
        end
      end

      EXTENSION_TYPES = [
        ExtensionType.new(identifier: 'product-details', description: 'Product extension'),
        ExtensionType.new(identifier: 'customer-details', description: 'Customer extension')
      ]

      def ask
        self.title = ask_title
        self.type = ask_type
        self.app = ask_app
      end

      protected

      attr_writer :app

      private

      def ask_title
        return title unless title.nil?
        CLI::UI::Prompt.ask('Extension Name')
      end

      def ask_type
        return type if EXTENSION_TYPES.include?(type)
        raise(ShopifyCli::Abort, 'Invalid extension type.') unless type.nil?
        CLI::UI::Prompt.ask('What type of extension would you like to create?') do |handler|
          EXTENSION_TYPES.each do |type|
            handler.option(type.description) { type.identifier }
          end
        end
      end

      def ask_app
        orgs = ShopifyCli::Helpers::Organizations.fetch_with_app(@ctx)
        orgs_with_apps = orgs.select {|org| org['apps'].any?}
        ctx.abort('There is no registered app. Create an app and try again') unless orgs_with_apps.any?

        if !api_key.nil?
          app = orgs_with_apps.reduce(nil) do |app, org|
            break app if app
            org.fetch('apps', []).find { |app| app['apiKey'] == api_key }
          end
          ctx.abort('The api key does not match any of the existing apps') if app.nil?
          return app
        else
          CLI::UI::Prompt.ask('Which app will you like to associate with the extension?') do |handler|
            orgs.each do |org|
              org['apps'].each do |app|
                handler.option(app['title'] + " by #{org['businessName'].to_s}") { app }
              end
            end
          end
        end
      end
    end
  end
end
