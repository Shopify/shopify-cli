require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class DeployScript < Form
      flag_arguments :api_key

      def ask
        self.api_key ||= ask_api_key
      end

      private

      def ask_api_key
        apps = Helpers::Organizations.fetch_apps(ctx)
        @api_key = if apps.count == 1
          apps.first["apiKey"]
        elsif apps.count == 0
          raise ShopifyCli::Abort, '{{x}} You need to create an app first'
        else
          CLI::UI::Prompt.ask('Which app do you want this script to belong to?') do |handler|
            apps.each { |app| handler.option(app["title"]) { app["apiKey"] } }
          end
        end
      end
    end
  end
end
