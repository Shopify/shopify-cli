# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetApp < ShopifyCLI::Task
      GRAPHQL_FILE = "get_app_by_api_key"

      RESPONSE_FIELD = %w(data)
      APP_FIELD = "app"

      def call(context:, api_key:)
        input = { api_key: api_key }

        response = ShopifyCLI::PartnersAPI.query(context, GRAPHQL_FILE, **input).dig(*RESPONSE_FIELD)
        context.abort(context.message("tasks.errors.parse_error")) if response.nil?

        Converters::AppConverter.from_hash(response.dig(APP_FIELD))
      end
    end
  end
end
