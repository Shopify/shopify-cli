require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      include ShopifyCli::Helpers::GraphQL::Queries

      def call(ctx)
        @ctx = ctx
        @api = Helpers::API.new(ctx: ctx, token: Helpers::AccessToken.read(ctx))
        @ctx.app_metadata = { schema: schema_file }
        schema_file
      end

      def get
        _, resp = @api.post(@api.graphql_url, @api.query_body(introspection))
        File.write(File.join(ShopifyCli::TEMP_DIR, 'shopify_schema.json'), JSON.dump(resp))
      rescue Helpers::API::APIRequestUnauthorizedError
        ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
        get
      end

      def shop_name
        project = ShopifyCli::Project.current
        env = Helpers::EnvFile.read(project.app_type,
          File.join(ShopifyCli::Project.current.directory, '.env'))
        @shop_name = env.shop
      end

      def schema_file
        @schema_file ||= begin
          path = File.join(ShopifyCli::TEMP_DIR, "shopify_schema.json")
          get unless File.exist?(path)
          JSON.parse(File.read(path))
        end
      end
    end
  end
end
