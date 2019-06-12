require 'shopify_cli'

module ShopifyCli
  module Tasks
    class Schema < ShopifyCli::Task
      include ShopifyCli::Helpers::GraphQL
      include ShopifyCli::Helpers::GraphQL::Queries

      def call(ctx)
        @ctx = ctx
        get
        if @response.code == '401'
          ShopifyCli::Tasks::AuthenticateShopify.call(ctx)
          get
        end
        @ctx.app_metadata = { schema: schema_file }
        schema_file
      end

      def get
        uri = URI.parse("https://#{shop_name}/admin/api/2019-04/graphql.json")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["X-Shopify-Access-Token"] = Helpers::AccessToken.read(@ctx)
        request["Content-Type"] = "application/json"
        request.body = query_body(introspection)
        @response = http.request(request)
        File.write(File.join(ShopifyCli::TEMP_DIR, 'shopify_schema.json'),
          @response.body.force_encoding('UTF-8'))
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
