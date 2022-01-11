# frozen_string_literal: true

module Script
  module Loaders
    module SpecificationHandler
      def self.load(project:, context:)
        identifier = project.specification_identifier
        Models::LazySpecificationHandler.new(identifier) do
          specifications = Models::Specifications.new(
            fetch_specifications: Tasks::FetchSpecifications.new(api_key: project.app.api_key, context: context)
          )

          unless specifications.valid?(identifier)
            context.abort(context.message("errors.unknown_type", project.specification_identifier))
          end

          specifications[identifier]
        end
      end
    end
  end
end
