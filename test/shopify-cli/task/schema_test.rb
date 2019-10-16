require 'test_helper'

module ShopifyCli
  module Tasks
    class SchemaTest < MiniTest::Test
      include TestHelpers::Project
      include TestHelpers::Constants

      def test_gets_schema
        Helpers::Store.expects(:exists?).returns(false)
        Helpers::Store.expects(:set).with(shopify_admin_schema: "{\"foo\":\"baz\"}")
        Helpers::Store.expects(:get).with(:shopify_admin_schema).returns("{\"foo\":\"baz\"}")
        ShopifyCli::Helpers::AdminAPI.expects(:query)
          .with(@context, 'admin_introspection')
          .returns(foo: "baz")
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end

      def test_gets_schema_if_already_downloaded
        Helpers::Store.expects(:exists?).returns(true)
        Helpers::Store.expects(:get).with(:shopify_admin_schema).returns("{\"foo\":\"baz\"}")
        assert_equal({ "foo" => "baz" }, ShopifyCli::Tasks::Schema.call(@context))
      end
    end
  end
end
