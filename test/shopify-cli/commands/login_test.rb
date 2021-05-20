require "test_helper"

module ShopifyCli
  module Commands
    class LoginTest < MiniTest::Test
      def setup
        super
        stub_shopify_org_confirmation
        ShopifyCli::Shopifolk.stubs(:check).returns(false)
      end

      def test_call_login_non_shopifolk
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login")
      end

      def test_call_login_shopifolk_not_acting_as_shopify
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Shopifolk.expects(:reset).once
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login")
      end

      def test_call_login_shopifolk_acting_as_shopify
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        stub_shopify_org_confirmation(response: true)
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).once
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login")
      end

      def test_call_login_shopifolk_acting_as_shopify_with_shop_flag
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        stub_shopify_org_confirmation(response: true)
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).once
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io").returns("testshop.myshopify.io")

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login --shop=testshop.myshopify.io")
      end

      def test_call_login_with_shop_flag
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io").returns("testshop.myshopify.io")
        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login --shop=testshop.myshopify.io")
      end

      def test_call_login_with_shop_and_password_flag
        CLI::UI::Prompt.expects(:ask).never

        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:ci?).returns(true)

        run_cmd("login --shop=testshop.myshopify.io --password=muffin")
      end

      def test_cant_call_login_with_password_flag_not_on_ci
        CLI::UI::Prompt.expects(:ask).never

        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin").never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        @context.expects(:ci?).returns(false)

        run_cmd("login --shop=testshop.myshopify.io --password=muffin")
      end

      def test_call_login_with_shop_and_password_env_vars
        CLI::UI::Prompt.expects(:ask).never

        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:ci?).returns(true)

        @context.expects(:getenv).with("SHOPIFY_SHOP").returns("testshop.myshopify.io")
        @context.expects(:getenv).with("SHOPIFY_PASSWORD").returns("muffin")

        run_cmd("login")
      end

      def test_login_with_shop_flag_bad_storenames
        [
          "testshop",
          "-badname.myshopify.io",
          "store.bad-doma.in",
          "https://store.myshopify.io",
          "https://store.myshopify.com",
        ].each do |store|
          CLI::UI::Prompt.expects(:ask).never

          exception = assert_raises ShopifyCli::Abort do
            run_cmd("login --shop=#{store}")
          end
          assert_equal(
            "{{x}} " + @context.message("core.login.invalid_shop", store),
            exception.message
          )
        end
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Login.help)
        run_cmd("help login")
      end

      private

      def stub_shopify_org_confirmation(response: false)
        CLI::UI::Prompt
          .stubs(:confirm)
          .with(includes("Are you working on a {{green:Shopify project}} that is {{red:not a theme}}?"), anything)
          .returns(response)
      end
    end
  end
end
