require 'test_helper'

module ShopifyCli
  module Tasks
    class SchemaTest < MiniTest::Test
      include TestHelpers::Project
      include ShopifyCli::Helpers::GraphQL::Queries
      include TestHelpers::Constants

      def test_gets_schema
        Helpers::Store.expects(:exist?).returns(false)
        Helpers::Store.expects(:set).with(Schema::SCHEMA_KEY, "{\"foo\":\"baz\"}")
        Helpers::Store.expects(:get).with(Schema::SCHEMA_KEY).returns("{\"foo\":\"baz\"}")
        ShopifyCli::Helpers::AdminAPI.expects(:query)
          .with(@context, introspection)
          .returns(foo: "baz")
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end

      def test_gets_schema_if_already_downloaded
        Helpers::Store.expects(:exist?).returns(true)
        Helpers::Store.expects(:get).with(Schema::SCHEMA_KEY).returns("{\"foo\":\"baz\"}")
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end
    end
  end
end
