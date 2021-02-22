# frozen_string_literal: true
require 'project_types/appconfig/test_helper'

module AppConfig
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        stub_shopify_org_confirmation
        ShopifyCli::Shopifolk.stubs(:check)
        ShopifyCli::ProjectType.load_type(:appconfig)
      end

      def test_it_will_fail_if_no_orgs_are_available
        stub_partner_req(
          'all_organizations',
          resp: { data: { organizations: { nodes: [] } } },
        )

        io = capture_io do
          form = ask(org_id: nil)
          assert_nil(form)
        end
        assert_match(@context.message('core.tasks.select_org_and_shop.error.partners_notice'), io.join)
        assert_match(@context.message('core.tasks.select_org_and_shop.error.no_organizations'), io.join)
      end

      def test_returns_all_defined_attributes_if_valid
        stub_org_request

        form = ask
        assert_equal('Test App', form.name)
        assert_equal('custom', form.type)
        assert_equal('https://testapp.com', form.app_url)
        assert_equal(['https://testapp.com/callback', 'https://testapp.com/auth'], form.allowed_redirection_urls)
        assert_equal(42, form.organization_id)
      end

      def test_name_can_be_provided_by_flag
        stub_org_request

        form = ask(name: 'My New app')
        assert_equal('My New app', form.name)
      end

      def test_type_can_be_provided_by_flag
        stub_org_request

        form = ask(type: 'public')
        assert_equal('public', form.type)
      end

      def test_app_url_can_be_provided_by_flag
        stub_org_request

        form = ask(app_url: 'https://appurl.ca')
        assert_equal('https://appurl.ca', form.app_url)
      end

      def test_allowed_redirection_urls_can_be_provided_by_flag
        stub_org_request

        form = ask(redirect_url: 'https://testapp.ca/callback,https://testapp.ca/auth')
        assert_equal(['https://testapp.ca/callback', 'https://testapp.ca/auth'], form.allowed_redirection_urls)
      end

      def test_type_is_prompted
        stub_org_request

        CLI::UI::Prompt.expects(:ask).with(@context.message('appconfig.forms.create.app_type.select')).returns('public')
        ask(type: nil)
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
        form = ask(org_id: nil)
        assert_equal(431, form.organization_id)
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
          form = ask(org_id: nil)
          assert_equal(421, form.organization_id)
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
        form = ask(org_id: 123)
        assert_equal(123, form.organization_id)
      end

      private

      def stub_org_request
        stub_partner_req(
          'find_organization',
          variables: { id: 42 },
          resp: {
            data: {
              organizations: {
                nodes: [
                  {
                    id: 42,
                    stores: { nodes: [{ shopDomain: 'shopdomain.myshopify.com', 'transferDisabled': true }] },
                  },
                ],
              },
            },
          }
        )
      end

      def ask(
        name: 'Test App',
        type: 'custom',
        app_url: "https://testapp.com",
        redirect_url: "https://testapp.com/callback,https://testapp.com/auth",
        org_id: 42
      )
        Create.ask(
          @context,
          [],
          name: name,
          type: type,
          app_url: app_url,
          allowed_redirection_urls: redirect_url,
          organization_id: org_id
        )
      end
    end
  end
end
