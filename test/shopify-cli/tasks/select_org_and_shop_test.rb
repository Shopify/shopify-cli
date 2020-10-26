require 'test_helper'

module ShopifyCli
  module Tasks
    class SelectOrgAndShopTest < MiniTest::Test
      include TestHelpers::Partners

      def test_user_will_be_prompted_if_more_than_one_organization
        stub_partner_req(
          'all_organizations',
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    'id': 421,
                    'businessName': "one",
                    'stores': { 'nodes': [{ 'shopDomain': 'store.myshopify.com' }] },
                  },
                  {
                    'id': 431,
                    'businessName': "two",
                    'stores': {
                      'nodes': [
                        { 'shopDomain': 'other.myshopify.com', 'transferDisabled': true },
                        { 'shopDomain': 'yet-another.myshopify.com' },
                      ],
                    },
                  },
                ],
              },
            },
          },
        )
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message('core.tasks.select_org_and_shop.organization_select'))
          .returns(431)
        form = call(org_id: nil, shop: nil)
        assert_equal(431, form[:organization_id])
        assert_equal('other.myshopify.com', form[:shop_domain])
      end

      def test_will_auto_pick_with_only_one_org
        stub_partner_req(
          'all_organizations',
          resp: {
            data: {
              organizations: {
                nodes: [{
                  'id': 421,
                  'businessName': "hoopy froods",
                  'stores': { 'nodes': [{ 'shopDomain': 'next.myshopify.com', 'transferDisabled': true }] },
                }],
              },
            },
          },
        )
        io = capture_io do
          form = call(org_id: nil, shop: nil)
          assert_equal(421, form[:organization_id])
          assert_equal('next.myshopify.com', form[:shop_domain])
        end
        assert_match(
          CLI::UI.fmt(@context.message('core.tasks.select_org_and_shop.organization', 'hoopy froods', 421)),
          io.join,
        )
      end

      def test_organization_will_be_fetched_if_id_is_provided_but_not_shop
        stub_partner_req(
          'find_organization',
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [{ shopDomain: 'shopdomain.myshopify.com', 'transferDisabled': true }] },
                  },
                ],
              },
            },
          }
        )
        form = call(org_id: 123, shop: nil)
        assert_equal(123, form[:organization_id])
        assert_equal('shopdomain.myshopify.com', form[:shop_domain])
      end

      def test_it_will_fail_if_no_orgs_are_available
        stub_partner_req(
          'all_organizations',
          resp: { data: { organizations: { nodes: [] } } },
        )

        assert_raises ShopifyCli::Abort do
          io = capture_io do
            form = call(org_id: nil, shop: nil)
            assert_nil(form)
          end
          assert_match(@context.message('core.tasks.select_org_and_shop.error.partners_notice'), io.join)
          assert_match(@context.message('core.tasks.select_org_and_shop.authentication_issue', ShopifyCli::TOOL_NAME),
                       io.join)
        end
      end

      def test_returns_no_shop_if_none_are_available
        stub_partner_req(
          'find_organization',
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
          form = call(org_id: 123, shop: nil)
          assert_nil form[:shop_domain]
        end
        log = io.join
        assert_match(CLI::UI.fmt(@context.message('core.tasks.select_org_and_shop.error.no_development_stores')), log)
        assert_match(CLI::UI.fmt(@context.message('core.tasks.select_org_and_shop.create_store', 123)), log)
      end

      def test_autopicks_only_shop
        stub_partner_req(
          'find_organization',
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [{ shopDomain: 'shopdomain.myshopify.com', 'transferDisabled': true }] },
                  },
                ],
              },
            },
          }
        )
        io = capture_io do
          form = call(org_id: 123, shop: nil)
          assert_equal('shopdomain.myshopify.com', form[:shop_domain])
        end
        assert_match(CLI::UI.fmt(
          @context.message('core.tasks.select_org_and_shop.development_store', 'shopdomain.myshopify.com')
        ), io.join)
      end

      def test_prompts_user_to_pick_from_shops
        stub_partner_req(
          'find_organization',
          variables: { id: 123 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 123,
                    stores: { nodes: [
                      { shopDomain: 'shopdomain.myshopify.com', 'transferDisabled': true },
                      { shopDomain: 'shop.myshopify.com', 'convertableToPartnerTest': true },
                      { shopDomain: 'other.myshopify.com' },
                    ] },
                  },
                ],
              },
            },
          }
        )

        CLI::UI::Prompt.expects(:ask)
          .with(
            @context.message('core.tasks.select_org_and_shop.development_store_select'),
            options: %w(shopdomain.myshopify.com shop.myshopify.com)
          )
          .returns('selected')
        form = call(org_id: 123, shop: nil)
        assert_equal('selected', form[:shop_domain])
      end

      private

      def call(org_id: 421, shop: 'store.myshopify.com')
        SelectOrgAndShop.call(
          @context,
          organization_id: org_id,
          shop_domain: shop,
        )
      end
    end
  end
end
