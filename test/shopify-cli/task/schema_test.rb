require 'test_helper'

module ShopifyCli
  module Tasks
    class SchemaTest < MiniTest::Test
      include TestHelpers::Context
      include ShopifyCli::Helpers::GraphQL::Queries
      include TestHelpers::Constants

      def setup
        super
        @dir = Dir.mktmpdir
        @command = ShopifyCli::Commands::Update.new
        redefine_constant(ShopifyCli, :TEMP_DIR, Dir.mktmpdir)
        FileUtils.mkdir("#{ShopifyCli::TEMP_DIR}/.shopify_schema")
        ShopifyCli::Project.expects(:current).returns(
          TestHelpers::FakeProject.new(
            directory: @context.root,
            config: {
              'app_type' => 'node',
            }
          )
        ).at_least_once
        ShopifyCli::Helpers::AccessToken.expects(:read).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        ).at_least_once
        ShopifyCli::Helpers::EnvFile.expects(:read).returns(
          ShopifyCli::Helpers::EnvFile.new(
            app_type: 'node',
            api_key: 'apikey',
            secret: 'secret',
            shop: 'myshop',
          )
        ).at_least_once
      end

      def test_gets_schema
        stub_request(:post, "https://myshop/admin/api/2019-04/graphql.json")
          .with(body: JSON.dump(query: introspection, variables: {}),
            headers: { 'X-Shopify-Access-Token' => 'accesstoken123' })
          .to_return(status: 200, body: "{}", headers: {})
        ShopifyCli::Tasks::Schema.call(@context)
      end

      def test_error_gets_access_token
        ShopifyCli::Tasks::AuthenticateShopify.expects(:call).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        )
        stub_request(:post, "https://myshop/admin/api/2019-04/graphql.json")
          .with(body: JSON.dump(query: introspection, variables: {}),
          headers: { 'X-Shopify-Access-Token' => 'accesstoken123' })
          .to_return(status: 401, body: "{}", headers: {})
        ShopifyCli::Tasks::Schema.call(@context)
      end
    end
  end
end
