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
      DRAFT_VERSION_FIELD = 'draftVersion'
      DRAFT_VERSION_REGISTRATION_ID_FIELD = %W(#{DRAFT_VERSION_FIELD} registrationId)
      DRAFT_VERSION_LAST_USER_INTERACTION_AT_FIELD = %W(#{DRAFT_VERSION_FIELD} lastUserInteractionAt)

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
          title: registration_hash[TITLE_FIELD],
          draft_version: Models::Version.new(
            registration_id: registration_hash.dig(*DRAFT_VERSION_REGISTRATION_ID_FIELD).to_i,
            last_user_interaction_at: Time.parse(registration_hash.dig(*DRAFT_VERSION_LAST_USER_INTERACTION_AT_FIELD)),
          ),
        )
      end
    end
  end
end
