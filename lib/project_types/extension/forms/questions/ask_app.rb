module Extension
  module Forms
    module Questions
      class AskApp
        include ShopifyCLI::MethodObject

        property! :ctx
        property :api_key
        property! :prompt,
          converts: :to_proc,
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          project_details.tap(&method(:prompt_for_app))
        end

        private

        def prompt_for_app(project_details)
          project_details.app =
            api_key.nil? ? choose_interactively(load_apps) : validate_app_ownership(api_key)
        end

        def validate_app_ownership(api_key)
          found_app = Tasks::GetApp.call(context: ctx, api_key: api_key)
          ctx.abort(ctx.message("create.invalid_api_key", api_key)) if found_app.nil?
          found_app
        end

        def choose_interactively(apps)
          prompt.call(ctx.message("create.ask_app")) do |handler|
            apps.each do |app|
              handler.option("#{app.title} by #{app.business_name}") { app }
            end
          end
        end

        def load_apps
          ctx.puts(@ctx.message("create.loading_apps"))
          apps = Tasks::GetApps.call(context: ctx)

          apps.empty? ? abort_no_apps : apps
        end

        def abort_no_apps
          ctx.puts(@ctx.message("create.no_apps"))
          ctx.puts(@ctx.message("create.learn_about_apps"))
          raise ShopifyCLI::AbortSilent
        end
      end
    end
  end
end
