# frozen_string_literal: true

module Extension
  module Models
    module SpecificationHandlers
      class Default
        attr_reader :specification

        def initialize(specification)
          @specification = specification
        end

        def identifier
          specification.identifier.to_s.upcase
        end

        def graphql_identifier
          specification.graphql_identifier.to_s.upcase
        end

        def name
          message("name") || specification.name
        end

        def tagline
          message("tagline") || ""
        end

        def config(context)
          argo.config(context)
        end

        def create(directory_name, context)
          argo.create(directory_name, identifier, context)
        end

        def extension_context(_context)
          nil
        end

        def valid_extension_contexts
          []
        end

        def serve(context)
          Features::ArgoServe.new(specification_handler: self, context: context).call
        end

        def renderer_package(context)
          argo.renderer_package(context)
        end

        protected

        def argo
          Features::Argo.new(
            git_template: specification.features.argo.git_template,
            renderer_package_name: specification.features.argo.renderer_package_name,
          )
        end

        private

        def message(key, *params)
          return unless messages.key?(key.to_sym)
          messages[key.to_sym] % params
        end

        def messages
          @messages ||= Messages::TYPES[identifier.downcase.to_sym] || {}
        end
      end
    end
  end
end
