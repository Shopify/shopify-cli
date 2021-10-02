module Extension
  module Forms
    module Questions
      class AskName
        include ShopifyCLI::MethodObject

        property! :ctx
        property :name
        property :prompt,
          accepts: ->(prompt) { prompt.respond_to?(:call) },
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          if theme_app_extension?(project_details)
            project_details.name = name || "theme-app-extension"
          else
            project_details.name = ask_with_reprompt(
              initial_value: name,
              break_condition: -> (current_name) { Models::Registration.valid_title?(current_name) },
              prompt_message: ctx.message("create.ask_name"),
              reprompt_message: ctx.message("create.invalid_name", Models::Registration::MAX_TITLE_LENGTH)
            )
          end
          project_details
        end

        private

        def theme_app_extension?(project_details)
          project_details&.type&.identifier == "THEME_APP_EXTENSION"
        end

        def ask_with_reprompt(initial_value:, break_condition:, prompt_message:, reprompt_message:)
          value = initial_value
          reprompt = false

          until break_condition.call(value)
            ctx.puts(reprompt_message) if reprompt
            value = prompt.call(prompt_message)&.strip
            reprompt = true
          end

          value
        end
      end
    end
  end
end
