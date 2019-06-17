require 'test_helper'

module ShopifyCli
  module Helpers
    class SchemaParserTest < MiniTest::Test
      def setup
        @test_obj = SchemaParser.new(
          schema: JSON.parse(File.read(File.join(ShopifyCli::ROOT, "test/fixtures/shopify_schema.json")))
        )
        @enum = {
          "kind" => "ENUM",
          "name" => "WebhookSubscriptionTopic",
          "enumValues" => [{ "name" => "APP_UNINSTALLED" }],
        }
      end

      def test_access
        assert_equal(@test_obj['WebhookSubscriptionTopic'], @enum)
      end

      def test_get_names_from_enum
        assert_equal(@test_obj.get_names_from_enum(@enum), ["APP_UNINSTALLED"])
      end
    end
  end
end
