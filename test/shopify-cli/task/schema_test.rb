require 'test_helper'

module ShopifyCli
  module Tasks
    class SchemaTest < MiniTest::Test
      include TestHelpers::Project
      include ShopifyCli::Helpers::GraphQL::Queries
      include TestHelpers::Constants

      def setup
        super
        ShopifyCli::Helpers::AccessToken.expects(:read).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        ).at_least_once
      end

      def test_gets_schema
        api_stub.expects(:query).with(introspection).returns("foo" => "baz")
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
        assert_equal('{"foo":"baz"}', File.read(Schema::FILEPATH))
      end

      def test_gets_schema_if_already_downloaded
        api_stub
        File.write(Schema::FILEPATH, '{"foo":"baz"}')
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end

      def test_error_gets_access_token
        api = api_stub
        ShopifyCli::Tasks::AuthenticateShopify.expects(:call).returns(
          File.read(File.join(ShopifyCli::ROOT, "test/fixtures/.apikey"))
        )
        api.expects(:query)
          .with(introspection)
          .returns("foo" => "baz")
        api.expects(:query)
          .with(introspection)
          .raises(Helpers::API::APIRequestUnauthorizedError)
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
        assert_equal('{"foo":"baz"}', File.read(Schema::FILEPATH))
      end

      private

      def api_stub
        api_stub = Object.new
        redefine_constant(Schema, :FILEPATH, File.join(Dir.mktmpdir, "shopify_schema.json"))
        ShopifyCli::Helpers::API.stubs(:new).returns(api_stub)
        api_stub
      end
    end
  end
end
