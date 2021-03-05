# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Commands
    class ExtensionCommand < ShopifyCli::Command
      def project
        @project ||= ExtensionProject.current
      end

      def extension_type
        @extension_type ||= begin
          identifier = project.extension_type_identifier
          Models::LazySpecificationHandler.new(identifier) do
            unless Extension.specifications.valid?(identifier)
              @ctx.abort(@ctx.message("errors.unknown_type", project.extension_type_identifier))
            end

            Extension.specifications[identifier]
          end
        end
      end
    end
  end
end
