# frozen_string_literal: true

module Script
  module Forms
    class AskApp < ShopifyCLI::Form
      attr_reader :app

      def ask
        apps = @xargs.fetch(:apps)

        unless @xargs[:acting_as_shopify_organization]
          apps = apps.select { |app| app["appType"] == "custom" }
        end

        raise Errors::NoExistingAppsError if apps.empty?

        @app =
          if apps.count > 1
            CLI::UI::Prompt.ask(ctx.message("script.application.ensure_env.app_select")) do |handler|
              apps.each do |app|
                handler.option(app["title"]) { app }
              end
            end
          else
            apps.first.tap do |app|
              ctx.puts(ctx.message("script.application.ensure_env.app", app["title"]))
            end
          end
      end
    end
  end
end
