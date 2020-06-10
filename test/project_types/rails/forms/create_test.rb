# frozen_string_literal: true
require 'project_types/rails/test_helper'

module Rails
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def test_returns_all_defined_attributes_if_valid
        form = ask
        assert_equal(form.name, 'test_app')
        assert_equal(form.title, 'Test App')
        assert_equal(form.organization_id, 42)
        assert_equal(form.shop_domain, 'shop.myshopify.com')
        assert_equal(form.db, 'sqlite3')
      end

      def test_title_can_be_provided_by_flag
        form = ask(title: 'My New App')
        assert_equal(form.name, 'my_new_app')
        assert_equal(form.title, 'My New App')
      end

      def test_type_can_be_provided_by_flag
        form = ask(type: 'public')
        assert_equal(form.type, 'public')
      end

      def test_type_is_validated
        io = capture_io do
          form = ask(type: "not_a_type")
          assert_nil(form)
        end
        assert_match(@context.message('rails.forms.create.error.invalid_app_type', 'not_a_type'), io.join)
      end

      def test_type_is_prompted
        CLI::UI::Prompt.expects(:ask).with(@context.message('rails.forms.create.app_type.select')).returns('public')
        ask(type: nil)
      end

      def test_db_can_be_provided_by_flag
        form = ask(db: 'sqlite3')
        assert_equal(form.db, 'sqlite3')
      end

      def test_db_is_validated
        io = capture_io do
          form = ask(db: "not_a_db")
          assert_nil(form)
        end
        assert_match(@context.message('rails.forms.create.error.invalid_db_type', 'not_a_db'), io.join)
      end

      def test_user_can_change_db_in_app
        CLI::UI::Prompt.expects(:confirm)
          .with(@context.message('rails.forms.create.db.want_select'),
                default: false)
          .returns(true)
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message('rails.forms.create.db.select'))
          .returns('mysql')
        form = ask(db: nil)
        assert_equal(form.db, 'mysql')
      end

      def test_user_asked_if_they_want_to_change_db
        CLI::UI::Prompt.expects(:confirm)
          .with(@context.message('rails.forms.create.db.want_select'),
                default: false)
          .returns(false)
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message('rails.forms.create.db.select'))
          .never
        form = ask(db: nil)
        assert_equal(form.db, 'sqlite3')
      end

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
        CLI::UI::Prompt.expects(:ask).returns(431)
        form = ask(org_id: nil, shop: nil)
        assert_equal(form.organization_id, 431)
        assert_equal(form.shop_domain, 'other.myshopify.com')
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
          form = ask(org_id: nil, shop: nil)
          assert_equal(form.organization_id, 421)
          assert_equal(form.shop_domain, 'next.myshopify.com')
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
        form = ask(org_id: 123, shop: nil)
        assert_equal(form.organization_id, 123)
        assert_equal(form.shop_domain, 'shopdomain.myshopify.com')
      end

      def test_it_will_fail_if_no_orgs_are_available
        stub_partner_req(
          'all_organizations',
          resp: { data: { organizations: { nodes: [] } } },
        )

        io = capture_io do
          form = ask(org_id: nil, shop: nil)
          assert_nil(form)
        end
        assert_match(@context.message('core.tasks.select_org_and_shop.error.partners_notice'), io.join)
        assert_match(@context.message('core.tasks.select_org_and_shop.error.no_organizations'), io.join)
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
          form = ask(org_id: 123, shop: nil)
          assert_nil form.shop_domain
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
          form = ask(org_id: 123, shop: nil)
          assert_equal(form.shop_domain, 'shopdomain.myshopify.com')
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
        form = ask(org_id: 123, shop: nil)
        assert_equal(form.shop_domain, 'selected')
      end

      private

      def ask(title: 'Test App', org_id: 42, shop: 'shop.myshopify.com', type: 'custom', db: 'sqlite3')
        Create.ask(
          @context,
          [],
          title: title,
          type: type,
          organization_id: org_id,
          shop_domain: shop,
          db: db,
        )
      end
    end
  end
end
