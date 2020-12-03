# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    class GetTypeDeclarations < ShopifyCli::Task
      GRAPHQL_FILE = 'get_type_declarations'

      RESPONSE_FIELD = %w(data)
      TYPE_DECLARATIONS_FIELD = %w(extensionTypeDeclarations)

      def call(context:)
        response = ShopifyCli::PartnersAPI.query(context, GRAPHQL_FILE).dig(*RESPONSE_FIELD)
        context.abort(context.message('tasks.errors.parse_error')) if response.nil?

        Converters::TypeDeclarationConverter.from_array(context, response.dig(*TYPE_DECLARATIONS_FIELD))
      end
    end
  end
end
