require "test_helper"

module ShopifyCli
  module Commands
    class LoginTest < MiniTest::Test
      def setup
        super
        stub_shopify_org_confirmation
        ShopifyCli::Shopifolk.stubs(:check).returns(false)
        stub_request(:head, "https://testshop.myshopify.io/admin")
          .to_return(status: 200)
        @stub_org = {
          "id" => "1234567",
          "businessName" => "Test partner org",
        }
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_all).with(@context).returns([@stub_org])
      end

      def test_call_login_non_shopifolk
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::DB.expects(:set).with(organization_id: 1234567).once
        Whoami.expects(:call).with([], "whoami")

        run_cmd("login")
      end

      def test_call_login_non_shopifolk_not_a_partner
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_all).with(@context).returns([])
        ShopifyCli::DB.expects(:set).with(organization_id: anything).never
        Whoami.expects(:call).with([], "whoami")

        run_cmd("login")
      end

      def test_call_login_shopifolk_not_acting_as_shopify
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        ShopifyCli::Shopifolk.expects(:reset).once
        ShopifyCli::DB.expects(:set).with(shop: anything).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::DB.expects(:set).with(organization_id: @stub_org["id"].to_i).once
        Whoami.expects(:call).with([], "whoami")

        run_cmd("login")
      end

      def test_call_login_shopifolk_acting_as_shopify
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        stub_shopify_org_confirmation(response: true)
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).once
        ShopifyCli::DB.expects(:set).with(shop: anything).never
        ShopifyCli::DB.expects(:set).with(organization_id: 1234567).once
        Whoami.expects(:call).with([], "whoami")

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)

        run_cmd("login")
      end

      def test_call_login_with_store_flag_doesnt_ask_acting_as_shopify
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io").once.returns("testshop.myshopify.io")
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::DB.expects(:set).with(organization_id: @stub_org["id"].to_i).once
        Whoami.expects(:call).with([], "whoami")

        run_cmd("login --store=testshop.myshopify.io")
      end

      def test_call_login_with_shop_flag_doesnt_ask_acting_as_shopify
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io").once.returns("testshop.myshopify.io")
        ShopifyCli::Shopifolk.stubs(:check).returns(true)
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::DB.expects(:set).with(organization_id: @stub_org["id"].to_i).once
        Whoami.expects(:call).with([], "whoami")

        run_cmd("login --shop=testshop.myshopify.io")
      end

      def test_call_login_with_store_and_password_flag
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).never
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:ci?).returns(true)

        run_cmd("login --store=testshop.myshopify.io --password=muffin")
      end

      def test_call_login_with_shop_and_password_flag
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).never
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:ci?).returns(true)

        run_cmd("login --shop=testshop.myshopify.io --password=muffin")
      end

      def test_cant_call_login_with_password_flag_not_on_ci
        CLI::UI::Prompt.expects(:confirm).never
        ShopifyCli::DB.expects(:get).with(:acting_as_shopify_organization).never
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin").never

        auth = mock
        auth.expects(:authenticate)
        IdentityAuth.expects(:new).with(ctx: @context).returns(auth)
        ShopifyCli::DB.expects(:set).with(organization_id: @stub_org["id"].to_i).once
        Whoami.expects(:call).with([], "whoami")

        @context.expects(:ci?).returns(false)

        run_cmd("login --store=testshop.myshopify.io --password=muffin")
      end

      def test_call_login_with_shop_and_password_env_vars
        CLI::UI::Prompt.expects(:ask).never
        ShopifyCli::DB.expects(:set).with(acting_as_shopify_organization: true).never
        ShopifyCli::DB.expects(:set).with(shop: "testshop.myshopify.io")
        ShopifyCli::DB.expects(:set).with(shopify_exchange_token: "muffin")
        IdentityAuth.expects(:new).never

        @context.expects(:ci?).returns(true)

        @context.expects(:getenv).with("SHOPIFY_SHOP").returns("testshop.myshopify.io")
        @context.expects(:getenv).with("SHOPIFY_PASSWORD").returns("muffin")

        run_cmd("login")
      end

      def test_login_with_shop_flag_bad_storenames
        store = "unexisting-shop"
        stub_request(:head, "https://#{store}.myshopify.com/admin")
          .to_return(status: 404)

        CLI::UI::Prompt.expects(:ask).never

        exception = assert_raises ShopifyCli::Abort do
          run_cmd("login --shop=#{store}")
        end
        assert_equal(
          "{{x}} " + @context.message("core.login.invalid_shop", store),
          exception.message
        )
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Login.help)
        run_cmd("help login")
      end

      def test_shop_to_permanent_domain
        stub_request(:head, "https://shoesbycolin.com/admin")
          .to_return(status: 302, headers: {
            "Location": "https://shoesbycolin.myshopify.com/admin",
          })
        stub_request(:head, "https://shoesbycolin.myshopify.com/admin")
          .to_return(status: 200)
        stub_request(:head, "https://shoesbycolin.myshopify.io/admin")
          .to_return(status: 200)
        stub_request(:head, "https://not-found.myshopify.com/admin")
          .to_return(status: 404)

        assert_equal("shoesbycolin.myshopify.com",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("https://shoesbycolin.com"))
        assert_equal("shoesbycolin.myshopify.com",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("shoesbycolin.com"))
        assert_equal("shoesbycolin.myshopify.com",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("https://shoesbycolin.com/admin"))
        assert_equal("shoesbycolin.myshopify.com",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("shoesbycolin"))
        assert_equal("shoesbycolin.myshopify.com",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("http://shoesbycolin.myshopify.com/admin"))
        assert_equal("shoesbycolin.myshopify.io",
          ShopifyCli::Commands::Login.shop_to_permanent_domain("http://shoesbycolin.myshopify.io/admin"))
        assert_nil(ShopifyCli::Commands::Login.shop_to_permanent_domain("not-found"))
      end

      private

      def stub_shopify_org_confirmation(response: false)
        CLI::UI::Prompt
          .stubs(:confirm)
          .with(includes("Are you working on a {{green:Shopify project}} on behalf of the"\
            " {{green:Shopify partners org}}?"), anything)
          .returns(response)
      end
    end
  end
end
