# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class ExtensionCommand < ShopifyCli::Command
      def project
        @project ||= ExtensionProject.current
      end

      def extension_type
        @extension_type ||= Models::Type.load_type(project.extension_type_identifier)
      end
    end
  end
end
