# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class UpdateDraft < ShopifyCLI::Task
      include UserErrors

      GRAPHQL_FILE = "extension_update_draft"

      RESPONSE_FIELD = %w(data extensionUpdateDraft)
      VERSION_FIELD = "extensionVersion"

      def call(context:, api_key:, registration_id:, config:, extension_context:)
        input = {
          api_key: api_key,
          registration_id: registration_id,
          config: JSON.generate(config),
          extension_context: extension_context,
        }
        response = ShopifyCLI::PartnersAPI.query(context, GRAPHQL_FILE, **input).dig(*RESPONSE_FIELD)
        context.abort(context.message("tasks.errors.parse_error")) if response.nil?

        abort_if_user_errors(context, response)
        Converters::VersionConverter.from_hash(context, response.dig(VERSION_FIELD))
      end
    end
  end
end
