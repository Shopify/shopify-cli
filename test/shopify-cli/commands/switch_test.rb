require "test_helper"

module ShopifyCli
  module Commands
    class SwitchTest < MiniTest::Test
      def test_can_switch_store
        original_shop = "testshop1.myshopify.com"
        new_shop = "testshop2.myshopify.com"
        ShopifyCli::AdminAPI.expects(:get_shop_or_abort).with(@context).returns(original_shop)
        ShopifyCli::Tasks::SelectOrgAndShop.expects(:call).with(@context).returns(
          { organization_id: 123, shop_domain: new_shop }
        )
        ShopifyCli::DB.expects(:set).with(shop: new_shop)
        @identity_auth_client = mock
        ShopifyCli::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)

        @context.expects(:puts).with(@context.message("core.switch.success", new_shop))

        run_cmd("switch")
      end

      def test_can_switch_store_with_shop_flag
        new_shop = "testshop2.myshopify.com"

        ShopifyCli::Commands::Login.expects(:validate_shop).with(new_shop).returns(new_shop)
        ShopifyCli::DB.expects(:set).with(shop: new_shop)

        @identity_auth_client = mock
        ShopifyCli::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)
        @context.expects(:puts).with(@context.message("core.switch.success", new_shop))

        run_cmd("switch --shop=#{new_shop}")
      end

      def test_aborts_if_no_shop
        ShopifyCli::DB.stubs(:exists?).returns(false)
        exception = assert_raises ShopifyCli::Abort do
          run_cmd("switch")
        end

        assert_equal(
          "{{x}} " + @context.message("core.populate.error.no_shop", ShopifyCli::TOOL_NAME),
          exception.message
        )
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Switch.help)
        run_cmd("help switch")
      end
    end
  end
end
