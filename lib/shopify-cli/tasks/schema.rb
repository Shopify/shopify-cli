require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      include ShopifyCli::Helpers::GraphQL::Queries

      SCHEMA_KEY = "shopify_admin_schema"

      def call(ctx)
        unless Helpers::Store.exists?(SCHEMA_KEY)
          Helpers::Store.set(SCHEMA_KEY, JSON.dump(Helpers::AdminAPI.query(ctx, introspection)))
        end
        schema = JSON.parse(Helpers::Store.get(SCHEMA_KEY))
        ctx.app_metadata = { schema: schema }
        schema
      end
    end
  end
end
