require 'test_helper'
require 'semantic/semantic'

module ShopifyCli
  module AppTypes
    class RailsBuildTest < MiniTest::Test
      def setup
        project_context('app_types', 'rails')
        @app = ShopifyCli::AppTypes::Rails.new(ctx: @context)
      end

      def test_generate_command
        {
          "SHOP_UPDATE" => "shop/update",
          "DRAFT_ORDER_UPDATE" => "draft_order/update",
          "APP_PURCHASE_ONE_TIME_CREATE" => "app_purchase_one_time/create",
        }.each do |topic, expected|
          actual = Rails.generate_command(topic)
          expected_cmd = "rails g shopify_app:add_webhook -t #{expected} -a https://example.com/webhooks/#{expected}"
          assert_equal expected_cmd, actual
        end
      end
    end
  end
end
