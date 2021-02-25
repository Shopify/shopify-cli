module Extension
  module Forms
    module Questions
      class AskType
        include ShopifyCli::MethodObject

        property! :ctx
        property :type
        property :prompt,
          converts: :to_proc,
          default: -> { CLI::UI::Prompt.method(:ask) }

        def call(project_details)
          project_details.tap do |p|
            p.type = type.nil? ? choose_type : validate_given_type(type)
          end
        end

        private

        def validate_given_type(type)
          return Extension.specifications[type] if Extension.specifications.valid?(type)
          ctx.abort(ctx.message("create.invalid_type")) unless type.nil?
        end

        def choose_type
          prompt.call(ctx.message("create.ask_type")) do |handler|
            Extension.specifications.each do |type|
              handler.option("#{type.name} #{type.tagline}") { type }
            end
          end
        end
      end
    end
  end
end
