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
          if template_required?(project_details)
            project_details.template = template || choose_interactively
          end
          project_details
        end

        private

        def template_required?(project_details)
          type = project_details&.type&.identifier
          (Models::DevelopmentServerRequirements.beta_enabled? &&
            Models::DevelopmentServerRequirements.type_supported?(type.downcase))
        end

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
