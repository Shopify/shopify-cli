require "test_helper"

module ShopifyCLI
  module Commands
    class WhoamiTest < MiniTest::Test
      def test_no_shop_no_org_id
        stub_db_setup(shop: nil, organization_id: nil)
        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch).never

        io = capture_io { run_cmd("whoami") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.whoami.not_logged_in", ShopifyCLI::TOOL_NAME),
          ]
        )
      end

      def test_yes_shop_no_org_id
        shop = "testshop2.myshopify.com"
        stub_db_setup(shop: shop, organization_id: nil)
        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch).never

        io = capture_io { run_cmd("whoami") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.whoami.logged_in_shop_only", shop),
          ]
        )
      end

      def test_no_shop_yes_org_id
        test_org = {
          "id" => "1234567",
          "businessName" => "test business name",
        }
        stub_db_setup(shop: nil, organization_id: test_org["id"])
        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch)
          .with(@context, id: test_org["id"])
          .once
          .returns(test_org)

        io = capture_io { run_cmd("whoami") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.whoami.logged_in_partner_only", test_org["businessName"]),
          ]
        )
      end

      def test_yes_shop_yes_org_id
        test_org = {
          "id" => "1234567",
          "businessName" => "test business name",
        }
        shop = "testshop2.myshopify.com"

        stub_db_setup(shop: shop, organization_id: test_org["id"])
        ShopifyCLI::PartnersAPI::Organizations.expects(:fetch)
          .with(@context, id: test_org["id"])
          .once
          .returns(test_org)

        io = capture_io { run_cmd("whoami") }
        assert_message_output(
          io: io,
          expected_content: [
            @context.message("core.whoami.logged_in_partner_and_shop", shop, test_org["businessName"]),
          ]
        )
      end

      private

      def stub_db_setup(shop:, organization_id:)
        ShopifyCLI::DB.stubs(:get).with(:shop).returns(shop)
        ShopifyCLI::DB.stubs(:get).with(:organization_id).returns(organization_id)
      end
    end
  end
end
