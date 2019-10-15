require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      def call(ctx)
        unless Helpers::Store.exists?(:shopify_admin_schema)
          schema = Helpers::AdminAPI.query(ctx, 'admin_introspection')
          Helpers::Store.set(shopify_admin_schema: JSON.dump(schema))
        end
        schema = JSON.parse(Helpers::Store.get(:shopify_admin_schema))
        ctx.app_metadata = { schema: schema }
        schema
      end
    end
  end
end
