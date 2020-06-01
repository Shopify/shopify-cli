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

      def test_calls_superclass_methods_when_no_flags
        ScriptForm.any_instance.stubs(:organization).returns({})
        ScriptForm.any_instance.expects(:ask_app_api_key).once
        ScriptForm.any_instance.expects(:ask_shop_domain).once
        ask(api_key: nil, shop_domain: nil)
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
