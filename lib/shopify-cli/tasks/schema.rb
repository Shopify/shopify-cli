require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      include ShopifyCli::Helpers::GraphQL::Queries

      FILEPATH = File.join(ShopifyCli::TEMP_DIR, "shopify_schema.json")

      def call(ctx)
        @ctx = ctx
        @api = Helpers::API.new(ctx: ctx, token: Helpers::AccessToken.read(ctx))
        @ctx.app_metadata = { schema: schema_file }
        schema_file
      end

      def get
        File.write(FILEPATH, JSON.dump(@api.query(introspection)))
      rescue Helpers::API::APIRequestUnauthorizedError
        ShopifyCli::Tasks::AuthenticateShopify.call(@ctx)
        retry
      end

      def shop_name
        @shop_name = Helpers::EnvFile.read.shop
      end

      def schema_file
        @schema_file ||= begin
          get unless File.exist?(FILEPATH)
          JSON.parse(File.read(FILEPATH))
        end
      end
    end
  end
end
