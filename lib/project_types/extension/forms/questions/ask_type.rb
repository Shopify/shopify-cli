module Extension
  module Forms
    module Questions
      class AskType
        include ShopifyCLI::MethodObject

        property! :ctx
        property :type
        property :prompt,
          converts: :to_proc,
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          specifications = Models::Specifications.new(
            fetch_specifications: Tasks::FetchSpecifications.new(context: ctx, api_key: project_details.app.api_key)
          )

          project_details.tap do |p|
            p.type = type.nil? ? choose_type(specifications) : validate_given_type(specifications, type)
          end
        end

        private

        def validate_given_type(specifications, type)
          return specifications[type] if specifications.valid?(type)
          ctx.abort(ctx.message("create.invalid_type")) unless type.nil?
        end

        def choose_type(specifications)
          abort_due_to_missing_specifications if specifications.none?

          prompt.call(ctx.message("create.ask_type")) do |handler|
            specifications.each do |type|
              handler.option("#{type.name} #{type.tagline}") { type }
            end
          end
        end

        def abort_due_to_missing_specifications
          ctx.puts(@ctx.message("create.no_available_extensions"))
          raise ShopifyCLI::AbortSilent
        end
      end
    end
  end
end
