# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class ExtensionCommand < ShopifyCli::Command
      def project
        @project ||= ExtensionProject.current
      end

      def extension_declaration
        @extension_declaration ||= Models::TypeDeclaration.new(type: project.extension_type_identifier)
      end

      def extension_type
        @extension_type ||= extension_declaration.load_type
      end
    end
  end
end
