require "test_helper"

module ShopifyCli
  module Commands
    class LoginTest < MiniTest::Test
      def test_call_login
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message("core.login.shop_prompt"), { allow_empty: false })
          .returns("testshop.myshopify.io")

        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io").returns("testshop.myshopify.io")
        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login")
      end

      def test_call_login_with_shop_flag
        CLI::UI::Prompt.expects(:ask).never

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

        run_cmd("login --shop=testshop.myshopify.io --password=muffin")
      end

      def test_call_login_with_shop_and_password_env_vars
        CLI::UI::Prompt.expects(:ask).never

        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:getenv).with("SHOPIFY_SHOP").returns("testshop.myshopify.io")
        @context.expects(:getenv).with("SHOPIFY_PASSWORD").returns("muffin")

        run_cmd("login")
      end

      def test_login_with_bad_storenames
        [
          "testshop",
          "-badname.myshopify.io",
          "store.bad-doma.in",
          "https://store.myshopify.io",
          "https://store.myshopify.com",
        ].each do |store|
          CLI::UI::Prompt.expects(:ask)
            .with(@context.message("core.login.shop_prompt"), { allow_empty: false })
            .returns(store)

          exception = assert_raises ShopifyCli::Abort do
            run_cmd("login")
          end
          assert_equal(
            "{{x}} " + @context.message("core.login.invalid_shop", store),
            exception.message
          )
        end
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
    end
  end
end
