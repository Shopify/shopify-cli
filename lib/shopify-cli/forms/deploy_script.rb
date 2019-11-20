require 'shopify_cli'
require 'uri'

module ShopifyCli
  module Forms
    class DeployScript < Form
      positional_arguments :extension_point, :name
      flag_arguments :app_key, :language

      def ask
        self.app_key ||= ask_app_key
        self.language ||= "ts"
      end

      private

      def ask_app_key
        apps = Helpers::Organizations.fetch_apps(ctx)
        @app_key = if apps.count == 1
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
