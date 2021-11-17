# frozen_string_literal: true

module Script
  module Forms
    class AskApp < ShopifyCLI::Form
      attr_reader :app

      def ask
        apps = @xargs[:apps]
        acting_as_shopify_organization = @xargs[:acting_as_shopify_organization]

        unless acting_as_shopify_organization
          apps = apps.select { |app| app["appType"] == "custom" }
        end

        if apps.count == 1
          default = apps.first
          ctx.puts(ctx.message("script.application.ensure_env.app", default["title"]))
          @app = default
        elsif apps.count > 0
          CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.app_select")) do |handler|
            apps.each do |app|
              handler.option(app["title"]) { @app = app }
            end
          end
        else
          raise Errors::NoExistingAppsError
        end
      end
    end
  end
end
