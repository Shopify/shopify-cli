# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Tasks
    class UpdateDraft < ShopifyCli::Task
      include UserErrors

      GRAPHQL_FILE = 'extension_update_draft'

      REGISTRATION_ID_FIELD = 'registrationId'
      CONTEXT_FIELD = 'context'
      LAST_USER_INTERACTION_AT_FIELD = 'lastUserInteractionAt'

      RESPONSE_FIELD = %w(data extensionUpdateDraft)
      VERSION_FIELD = 'extensionVersion'

      PARSE_ERROR = 'Unable to parse response from Partners Dashboard.'

      def call(context:, api_key:, registration_id:, config:, extension_context:)
        input = {
          api_key: api_key,
          registration_id: registration_id,
          config: JSON.generate(config),
          extension_context: extension_context
        }

        response = ShopifyCli::PartnersAPI.query(context, GRAPHQL_FILE, input).dig(*RESPONSE_FIELD)
        context.abort(PARSE_ERROR) if response.nil?

        abort_if_user_errors(context, response)
        response_to_version(context, response)
      end

      private

      def response_to_version(context, response)
        version_hash = response.dig(VERSION_FIELD)
        context.abort(PARSE_ERROR) if version_hash.nil?

        Models::Version.new(
          registration_id: version_hash[REGISTRATION_ID_FIELD].to_i,
          context: version_hash[CONTEXT_FIELD],
          last_user_interaction_at: Time.parse(version_hash[LAST_USER_INTERACTION_AT_FIELD])
        )
      end
    end
  end
end
