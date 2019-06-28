require 'test_helper'

module ShopifyCli
  module Tasks
    class SchemaTest < MiniTest::Test
      include TestHelpers::Project
      include ShopifyCli::Helpers::GraphQL::Queries
      include TestHelpers::Constants

      def setup
        super
        @dir = Dir.mktmpdir
        @command = ShopifyCli::Commands::Update.new
        redefine_constant(ShopifyCli, :TEMP_DIR, Dir.mktmpdir)
        FileUtils.mkdir("#{ShopifyCli::TEMP_DIR}/.shopify_schema")
        ShopifyCli::Helpers::API.any_instance.stubs(:latest_api_version)
          .returns('2019-04')
        ShopifyCli::Helpers::AccessToken.expects(:read).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        ).at_least_once
      end

      def test_gets_schema
        stub_request(:post, "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json")
          .with(body: JSON.dump(query: introspection, variables: {}),
            headers: { 'X-Shopify-Access-Token' => 'accesstoken123' })
          .to_return(status: 200, body: '{"foo":"baz"}', headers: {})
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
        assert_equal('{"foo":"baz"}', File.read(File.join(ShopifyCli::TEMP_DIR, 'shopify_schema.json')))
      end

      def test_gets_schema_if_already_downloaded
        File.write(File.join(ShopifyCli::TEMP_DIR, 'shopify_schema.json'), '{"foo":"baz"}')
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end

      def test_error_gets_access_token
        ShopifyCli::Tasks::AuthenticateShopify.expects(:call).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        )
        stub_request(:post, "https://my-test-shop.myshopify.com/admin/api/2019-04/graphql.json")
          .with(body: JSON.dump(query: introspection, variables: {}),
          headers: { 'X-Shopify-Access-Token' => 'accesstoken123' })
          .to_return(
            { status: 401, body: "{}", headers: {} },
            status: 200, body: '{}', headers: {}
          )
        ShopifyCli::Tasks::Schema.call(@context)
      end
    end
  end
end
