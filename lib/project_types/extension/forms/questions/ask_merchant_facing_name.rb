module Extension
  module Forms
    module Questions
      class AskMerchantFacingName
        include ShopifyCLI::MethodObject

        property! :ctx
        property :merchant_facing_name
        property :prompt,
          accepts: ->(prompt) { prompt.respond_to?(:call) },
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          return project_details unless checkout_ui_extension?(project_details)
          
          project_details.tap do |project_details|
            project_details.merchant_facing_name = ask_with_reprompt(
              initial_value: merchant_facing_name,
              break_condition: -> (merchant_facing_name) { validate_merchant_facing_name(merchant_facing_name) },
              prompt_message: ctx.message("create.ask_merchant_facing_name"),
              reprompt_message: ctx.message(
                "create.invalid_ask_merchant_facing_name", 
                Models::SpecificationHandlers::CheckoutUiExtension::MAX_MERCHANT_FACING_NAME_LENGTH,
              )
            )
          end
        end

        private

        def checkout_ui_extension?(project_details)
          project_details&.type&.identifier == "CHECKOUT_UI_EXTENSION"
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

        def validate_merchant_facing_name(name)
          Models::SpecificationHandlers::CheckoutUiExtension.valid_merchant_facing_name?(name)
        end
      end
    end
  end
end
