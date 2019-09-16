require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      include ShopifyCli::Helpers::GraphQL::Queries

      def call(ctx)
        unless Helpers::Store.exists?(:shopify_admin_schema)
          Helpers::Store.set(shopify_admin_schema: JSON.dump(Helpers::AdminAPI.query(ctx, introspection)))
        end
        schema = JSON.parse(Helpers::Store.get(:shopify_admin_schema))
        ctx.app_metadata = { schema: schema }
        schema
      end
    end
  end
end
