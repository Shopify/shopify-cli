require 'shopify_cli'

module ShopifyCli
  module Tasks
    class GetSchema < ShopifyCli::Task
      def call(ctx)
        unless File.file?("#{ShopifyCli::TEMP_DIR}/shopify_schema.json")
          ShopifyCli::Helpers::ShopifySchema.get
        end
        @file = File.read("#{ShopifyCli::TEMP_DIR}/shopify_schema.json")
        schema = JSON.parse(@file)
        ctx.app_metadata = { schema: schema }
        schema
      end
    end
  end
end
