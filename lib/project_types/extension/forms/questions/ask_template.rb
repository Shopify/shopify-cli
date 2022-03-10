module Extension
  module Forms
    module Questions
      class AskTemplate
        include ShopifyCLI::MethodObject

        property! :ctx
        property :template, accepts: Models::ServerConfig::Development::VALID_TEMPLATES
        property :prompt,
          accepts: ->(prompt) { prompt.respond_to?(:call) },
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          type = project_details&.type&.identifier
          if Models::DevelopmentServerRequirements.supported?(type)
            project_details.template = template || choose_interactively
          end
          project_details
        end

        private

        def choose_interactively
          prompt.call(ctx.message("create.ask_template")) do |handler|
            Models::ServerConfig::Development::VALID_TEMPLATES.each do |template|
              handler.option(template) { template }
            end
          end
        end
      end
    end
  end
end
