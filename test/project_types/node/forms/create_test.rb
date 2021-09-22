# frozen_string_literal: true
require "project_types/rails/test_helper"

module Node
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:node)
      end

      def test_returns_all_defined_attributes_if_valid
        form = ask
        assert_equal("test_app", form.name)
        assert_equal("Test App", form.title)
        assert_equal(42, form.organization_id)
        assert_equal("shop.myshopify.com", form.shop_domain)
      end

      def test_title_can_be_provided_by_flag
        form = ask(title: "My New App")
        assert_equal("my_new_app", form.name)
        assert_equal("My New App", form.title)
      end

      def test_aborts_if_title_includes_shopify
        io = capture_io do
          form = ask(title: "Shopify")
          assert_nil(form)
        end
        assert_match(@context.message("node.forms.create.error.invalid_app_name"), io.join)
      end

      def test_type_can_be_provided_by_flag
        form = ask(type: "public")
        assert_equal("public", form.type)
      end

      def test_type_is_validated
        io = capture_io do
          form = ask(type: "not_a_type")
          assert_nil(form)
        end
        assert_match(@context.message("node.forms.create.error.invalid_app_type", "not_a_type"), io.join)
      end

      def test_type_is_prompted
        CLI::UI::Prompt.expects(:ask).with(@context.message("node.forms.create.app_type.select")).returns("public")
        ask(type: nil)
      end

      def test_user_will_be_prompted_if_more_than_one_organization
        stub_partner_req(
          "all_organizations",
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': { 'nodes': [{ 'shopDomain': "store.myshopify.com" }] },
                  },
                  {
                    'id': 431,
                    'businessName': "two",
                    'stores': {
                      'nodes': [
                        { 'shopDomain': "other.myshopify.com", 'transferDisabled': true },
                        { 'shopDomain': "yet-another.myshopify.com" },
                      ],
                    },
                  },
                ],
              },
            },
          },
        )
        CLI::UI::Prompt.expects(:ask).returns(431)
        form = ask(org_id: nil, shop: nil)
        assert_equal(431, form.organization_id)
        assert_equal("other.myshopify.com", form.shop_domain)
      end

      def test_will_auto_pick_with_only_one_org
        stub_partner_req(
          "all_organizations",
          resp: {
            data: {
              organizations: {
                nodes: [{
                  'id': 421,
                  'businessName': "hoopy froods",
                  'stores': { 'nodes': [{ 'shopDomain': "next.myshopify.com", 'transferDisabled': true }] },
                }],
              },
            },
          },
        )
        io = capture_io do
          form = ask(org_id: nil, shop: nil)
          assert_equal(421, form.organization_id)
          assert_equal("next.myshopify.com", form.shop_domain)
        end
        assert_match(
          CLI::UI.fmt(@context.message("core.tasks.select_org_and_shop.organization", "hoopy froods", 421)),
          io.join,
        )
      end

      def test_organization_will_be_fetched_if_id_is_provided_but_not_shop
        stub_partner_req(
          "find_organization",
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [{ shopDomain: "shopdomain.myshopify.com", 'transferDisabled': true }] },
                  },
                ],
              },
            },
          }
        )
        form = ask(org_id: 123, shop: nil)
        assert_equal(123, form.organization_id)
        assert_equal("shopdomain.myshopify.com", form.shop_domain)
      end

      def test_it_will_fail_if_no_orgs_are_available
        stub_partner_req(
          "all_organizations",
          resp: { data: { organizations: { nodes: [] } } },
        )

        io = capture_io do
          form = ask(org_id: nil, shop: nil)
          assert_nil(form)
        end
        assert_match(@context.message("core.tasks.select_org_and_shop.error.no_organizations"), io.join)
      end

      def test_returns_no_shop_if_none_are_available
        stub_partner_req(
          "find_organization",
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [{ id: 123, stores: { nodes: [] } }],
              },
            },
          }
        )

        io = capture_io do
          form = ask(org_id: 123, shop: nil)
          assert_nil form.shop_domain
        end
        log = io.join
        assert_match(CLI::UI.fmt(@context.message("core.tasks.select_org_and_shop.error.no_development_stores")), log)
        assert_match(CLI::UI.fmt(@context.message("core.tasks.select_org_and_shop.create_store", 123)), log)
      end

      def test_autopicks_only_shop
        stub_partner_req(
          "find_organization",
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [{ shopDomain: "shopdomain.myshopify.com", 'transferDisabled': true }] },
                  },
                ],
              },
            },
          }
        )
        io = capture_io do
          form = ask(org_id: 123, shop: nil)
          assert_equal("shopdomain.myshopify.com", form.shop_domain)
        end
        assert_match(CLI::UI.fmt(
          @context.message("core.tasks.select_org_and_shop.development_store", "shopdomain.myshopify.com")
        ), io.join)
      end

      def test_prompts_user_to_pick_from_shops
        stub_partner_req(
          "find_organization",
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [
                      { shopDomain: "shopdomain.myshopify.com", 'transferDisabled': true },
                      { shopDomain: "shop.myshopify.com", 'convertableToPartnerTest': true },
                      { shopDomain: "other.myshopify.com" },
                    ] },
                  },
                ],
              },
            },
          }
        )

        CLI::UI::Prompt.expects(:ask)
          .with(
            @context.message("core.tasks.select_org_and_shop.development_store_select"),
            options: %w(shopdomain.myshopify.com shop.myshopify.com)
          )
          .returns("selected")
        form = ask(org_id: 123, shop: nil)
        assert_equal("selected", form.shop_domain)
      end

      private

      def ask(title: "Test App", org_id: 42, shop: "shop.myshopify.com", type: "custom")
        Create.ask(
          @context,
          [],
          title: title,
          type: type,
          organization_id: org_id,
          shop_domain: shop,
        )
      end
    end
  end
end
