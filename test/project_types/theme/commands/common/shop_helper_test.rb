# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/commands/common/shop_helper"

module Theme
  class Command
    module Common
      class RootHelperTest < MiniTest::Test
        include Common::ShopHelper

        def setup
          super
          @ctx = TestHelpers::FakeContext.new
        end

        def test_shop_when_shop_is_present
          ShopifyCLI::DB.stubs(:exists?).returns(true)
          ShopifyCLI::DB.stubs(:get).with(:shop).returns("store.myshopify.com")

          assert_equal("store.myshopify.com", shop)
        end

        def test_shop_when_shop_is_not_present
          assert_raises(ShopifyCLI::Abort) { shop }
        end
      end
    end
  end
end
