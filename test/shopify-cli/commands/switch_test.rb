require "test_helper"

module ShopifyCLI
  module Commands
    class SwitchTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::DB.stubs(:get).with(:acting_as_shopify_organization).returns(false)
      end

      def test_can_switch_store_no_org_id
        old_shop = "testshop1.myshopify.com"
        new_shop = "testshop2.myshopify.com"
        ShopifyCLI::DB.expects(:exists?).with(:shop).returns(true)
        ShopifyCLI::DB.expects(:get).with(:shop).returns(old_shop)
        ShopifyCLI::DB.expects(:get).with(:organization_id).returns(nil)
        ShopifyCLI::Tasks::SelectOrgAndShop.expects(:call).with(@context).returns(
          { organization_id: 123, shop_domain: new_shop }
        )
        ShopifyCLI::DB.expects(:set).with(shop: new_shop)
        @identity_auth_client = mock
        ShopifyCLI::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)

        io = capture_io { run_cmd("switch") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.switch.success", new_shop),
          ]
        )
      end

      def test_can_switch_store_with_org_id
        new_shop = "testshop2.myshopify.com"
        ShopifyCLI::DB.expects(:get).with(:organization_id).returns("123")
        ShopifyCLI::Tasks::SelectOrgAndShop.expects(:call).with(@context, organization_id: "123").returns(
          { organization_id: 123, shop_domain: new_shop }
        )
        ShopifyCLI::DB.expects(:set).with(shop: new_shop)
        @identity_auth_client = mock
        ShopifyCLI::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)

        io = capture_io { run_cmd("switch") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.switch.success", new_shop),
          ]
        )
      end

      def test_can_switch_store_with_store_flag
        new_shop = "testshop2.myshopify.com"

        ShopifyCLI::Commands::Login.expects(:validate_shop).with(new_shop).returns(new_shop)
        ShopifyCLI::DB.expects(:set).with(shop: new_shop)

        @identity_auth_client = mock
        ShopifyCLI::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)

        io = capture_io { run_cmd("switch --store=#{new_shop}") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.switch.success", new_shop),
          ]
        )
      end

      def test_can_switch_store_with_shop_flag
        new_shop = "testshop2.myshopify.com"

        ShopifyCLI::Commands::Login.expects(:validate_shop).with(new_shop).returns(new_shop)
        ShopifyCLI::DB.expects(:set).with(shop: new_shop)

        @identity_auth_client = mock
        ShopifyCLI::IdentityAuth
          .expects(:new)
          .with(ctx: @context).returns(@identity_auth_client)
        @identity_auth_client
          .expects(:reauthenticate)

        io = capture_io { run_cmd("switch --shop=#{new_shop}") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.switch.success", new_shop),
          ]
        )
      end

      def test_aborts_if_no_shop_no_org_id
        ShopifyCLI::DB.stubs(:exists?).returns(false)
        ShopifyCLI::DB.expects(:get).with(:organization_id).returns(nil)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) { run_cmd("switch") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.populate.error.no_shop", ShopifyCLI::TOOL_NAME),
          ]
        )
      end

      def test_help_argument_calls_help
        io = capture_io { run_cmd("help switch") }
        assert_message_output(
          io: io,
          expected_content: [
            ShopifyCLI::Commands::Switch.help,
          ]
        )
      end

      def test_cant_switch_if_shopifolk
        ShopifyCLI::DB.expects(:get).with(:acting_as_shopify_organization).once.returns(true)
        ShopifyCLI::DB.expects(:set).with(shop: anything).never
        ShopifyCLI::IdentityAuth.expects(:new).never

        io = capture_io { run_cmd("switch") }

        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.switch.disabled_as_shopify_org"),
          ]
        )
      end
    end
  end
end
