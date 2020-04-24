# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    class CreateExtension < ShopifyCli::Task
      include UserErrors

      GRAPHQL_FILE = 'extension_create'
      ID_FIELD = 'id'
      TYPE_FIELD = 'type'
      TITLE_FIELD = 'title'
      RESPONSE_FIELD = %w(data extensionCreate)
      REGISTRATION_FIELD = 'extensionRegistration'
      PARSE_ERROR = 'Unable to parse response from Partners Dashboard.'


      def call(context:, api_key:, type:, title:, config:, extension_context: nil)
        input = {
          api_key: api_key,
          type: type,
          title: title,
          config: JSON.generate(config),
          extension_context: extension_context
        }

        response = ShopifyCli::PartnersAPI.query(context, GRAPHQL_FILE, input).dig(*RESPONSE_FIELD)
        context.abort(PARSE_ERROR) if response.nil?

        abort_if_user_errors(context, response)
        response_to_registration(context, response)
      end

      private

      def response_to_registration(context, response)
        registration_hash = response.dig(REGISTRATION_FIELD)
        context.abort(PARSE_ERROR) if registration_hash.nil?

        Models::Registration.new(
          id: registration_hash[ID_FIELD].to_i,
          type: registration_hash[TYPE_FIELD],
          title: registration_hash[TITLE_FIELD]
        )
      end
    end
  end
end
