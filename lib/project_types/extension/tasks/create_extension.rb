# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class CreateExtension < ShopifyCLI::Task
      include UserErrors

      GRAPHQL_FILE = "extension_create"

      RESPONSE_FIELD = %w(data extensionCreate)
      REGISTRATION_FIELD = "extensionRegistration"

      def call(context:, api_key:, type:, title:, config:, extension_context: nil)
        input = {
          api_key: api_key,
          type: type,
          title: title,
          config: JSON.generate(config),
          extension_context: extension_context,
        }

        response = ShopifyCLI::PartnersAPI.query(context, GRAPHQL_FILE, **input).dig(*RESPONSE_FIELD)
        context.abort(context.message("tasks.errors.parse_error")) if response.nil?

        abort_if_user_errors(context, response)
        Converters::RegistrationConverter.from_hash(context, response.dig(REGISTRATION_FIELD))
      end
    end
  end
end
