# frozen_string_literal: true
require "shopify_cli"

module Extension
  module Tasks
    class GetProduct < ShopifyCLI::Task
      API_VERSION = "2021-07"
      GRAPHQL_FILE = "get_variant_id"

      def call(context, shop)
        response = ShopifyCLI::AdminAPI.query(
          context,
          GRAPHQL_FILE,
          shop: shop,
          api_version: API_VERSION
        )
        context.abort(context.message("tasks.errors.store_error")) if response.nil?
        Converters::ProductConverter.from_hash(response)
      end
    end
  end
end
