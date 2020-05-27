# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class ScriptFormTest < MiniTest::Test
      include TestHelpers::FakeUI

      def test_organizations_fetch_once
        UI::StrictSpinner.expects(:spin).with('Fetching organizations').yields(FakeSpinner.new).returns(true).once
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).returns(true).once
        2.times { form.send(:organizations) }
      end

      def test_no_organization_raises_error
        form.expects(:organizations).returns([])
        assert_raises(Errors::NoExistingOrganizationsError) { form.send(:ask_organization) }
      end

      def test_one_organization_auto_selects
        org = { 'businessName' => 'test' }
        @context.expects(:puts).with(@context.message(
          'script.forms.script_form.using_organization',
          'test'
        ))
        form.expects(:organizations).returns([org]).at_least_once
        assert_equal org, form.send(:ask_organization)
      end

      def test_multiple_organizations_invoke_prompt
        org1 = { 'id' => '1', 'businessName' => 'org1' }
        org2 = { 'id' => '2', 'businessName' => 'org2' }
        form.expects(:organizations).returns([org1, org2]).at_least_once
        CLI::UI::Prompt.expects(:ask).returns(org1['id'])
        assert_equal org1, form.send(:ask_organization)
      end

      def test_no_apps_raises_error
        assert_raises(Errors::NoExistingAppsError) { form.send(:ask_app_api_key, []) }
      end

      def test_one_app_auto_selects
        app = { 'apiKey' => 'key', 'title' => 'title' }
        @context.expects(:puts).with(@context.message(
          'script.forms.script_form.using_app',
          title: 'title',
          api_key: 'key'
        ))
        assert_equal 'key', form.send(:ask_app_api_key, [app])
      end

      def test_multiple_apps_invoke_prompt
        app1 = { 'apiKey' => 'key1', 'title' => 'title1' }
        app2 = { 'apiKey' => 'key2', 'title' => 'title2' }
        CLI::UI::Prompt.expects(:ask).returns(app1['apiKey'])
        assert_equal 'key1', form.send(:ask_app_api_key, [app1, app2])
      end

      def test_no_shops_raises_error
        org = { 'businessName' => 'org1', 'stores' => [] }
        assert_raises(Errors::NoExistingStoresError) { form.send(:ask_shop_domain, org) }
      end

      def test_one_shop_auto_selects
        shop = { 'shopDomain' => 'domain' }
        org = { 'businessName' => 'org1', 'stores' => [shop] }
        @context.expects(:puts).with(@context.message(
          'script.forms.script_form.using_development_store',
          domain: 'domain'
        ))
        assert_equal 'domain', form.send(:ask_shop_domain, org)
      end

      def test_multiple_shops_invoke_prompt
        shop1 = { 'shopDomain' => 'domain1' }
        shop2 = { 'shopDomain' => 'domain2' }
        org = { 'businessName' => 'org1', 'stores' => [shop1, shop2] }
        CLI::UI::Prompt.expects(:ask).returns(shop1['shopDomain'])
        assert_equal 'domain1', form.send(:ask_shop_domain, org)
      end

      private

      def form
        @form ||= ScriptForm.new(@context, [], [])
      end
    end
  end
end
