# frozen_string_literal: true

module Extension
  module Forms
    module Questions
      class AskRegistration
        include ShopifyCLI::MethodObject

        property! :ctx
        property! :type
        property! :prompt,
          converts: :to_proc,
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          project_details.tap(&method(:prompt_for_registration))
        end

        private

        def prompt_for_registration(project_details)
          apps_and_registrations = load_registrations(type)
          app, registration = choose_interactively(apps_and_registrations)
          project_details.app = app
          project_details.registration = registration
        end

        def choose_interactively(apps_and_registrations)
          prompt.call(ctx.message("connect.ask_registration")) do |handler|
            apps_and_registrations.each do |(app, extension)|
              handler.option("#{app.title} by #{app.business_name}: #{extension.title}") { [app, extension] }
            end
          end
        end

        def load_registrations(type)
          registrations = []
          loading_extensions = @ctx.message("connect.loading_extensions")

          CLI::UI::Spinner.spin(loading_extensions) do |_spinner|
            registrations += Tasks::GetExtensions.call(context: ctx, type: type)
          end

          registrations.empty? ? abort_no_registrations : registrations
        end

        def abort_no_registrations
          ctx.puts(@ctx.message("connect.no_extensions", type))
          ctx.puts(@ctx.message("connect.learn_about_extensions"))
          raise ShopifyCLI::AbortSilent
        end
      end
    end
  end
end
