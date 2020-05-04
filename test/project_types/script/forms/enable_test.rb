# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class EnableTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI

      def test_use_provided_flags
        form = ask
        assert_equal(form.api_key, 'fakekey')
        assert_equal(form.shop_domain, 'shop.myshopify.com')
      end

      def test_raises_when_no_apps_available
        stub_organization
        assert_raises Errors::NoExistingAppsError do
          ask(api_key: nil)
        end
      end

      def test_organizations_fetch_once
        UI::StrictSpinner.expects(:spin).with('Fetching organizations').yields(FakeSpinner.new).returns(true).once
        ShopifyCli::PartnersAPI::Organizations.expects(:fetch_with_app).returns(true).once
        form = Enable.new(@context, [], [])
        2.times { form.send(:organizations) }
      end

      def test_pick_singular_app
        stub_organization(apps: [{ "apiKey" => 1234 }])
        ShopifyCli::PartnersAPI::Organizations.stubs(:fetch_apps).returns([{ "apiKey" => 1234 }])
        form = ask(api_key: nil)
        assert_equal 1234, form.api_key
      end

      def test_display_selection_for_apps
        stub_organization(apps: [{ "apiKey" => 1234 }, { "apiKey" => 1267 }])
        CLI::UI::Prompt.expects(:ask)
          .with('Which app is the script deployed to?')
          .returns(1267)
        form = ask(api_key: nil)
        assert_equal(form.api_key, 1267)
      end

      def test_raises_when_no_shops_available
        stub_organization
        assert_raises Errors::NoExistingStoresError do
          ask(shop_domain: nil)
        end
      end

      def test_pick_singular_shop
        stub_organization(stores: [{ 'shopId' => 1234, 'shopDomain' => 'domain' }])
        form = ask(shop_domain: nil)
        assert_equal 'domain', form.shop_domain
      end

      def test_display_selection_for_shops
        stub_organization(stores: [{ 'shopId' => 1, 'shopDomain' => 'a' }, { 'shopId' => 2, 'shopDomain' => 'b' }])
        CLI::UI::Prompt.expects(:ask)
          .with('Which development store is the app installed on?', options: %w(a b))
          .returns('a')
        form = ask(shop_domain: nil)
        assert_equal(form.shop_domain, 'a')
      end

      private

      def stub_organization(apps: [], stores: [])
        Enable.any_instance.stubs(:organization).returns({ 'apps' => apps, 'stores' => stores })
      end

      def ask(api_key: 'fakekey', shop_domain: 'shop.myshopify.com')
        Enable.ask(
          @context,
          [],
          api_key: api_key,
          shop_domain: shop_domain
        )
      end
    end
  end
end
