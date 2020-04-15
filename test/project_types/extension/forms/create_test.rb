# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def setup
        super
        stub_get_organizations
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def returns_defined_attributes_if_valid
        form = ask
        assert_equal form.title, 'test-extension'
        assert_equal form.type, 'product-details'

      end

      def test_accepts_product_details_as_type
        form = ask
        assert_equal form.type, 'product-details'
      end

      def test_accepts_customer_details_as_type
        form = ask(type: 'customer-details')
        assert_equal form.type, 'customer-details'
      end

      def test_prompts_the_user_to_choose_a_title_if_no_title_was_provided
        CLI::UI::Prompt.expects(:ask).with('Extension Name')

        capture_io do
          ask(title: nil)
        end
      end

      def test_prompts_the_user_to_choose_a_type_if_an_unknown_type_was_provided_as_flag
        io = capture_io do
          ask(type: 'unknown-type')
        end

        assert_match('Invalid extension type.', io.join)
      end

      def test_prompts_the_user_to_choose_a_type_if_no_type_was_provided
        CLI::UI::Prompt.expects(:ask).with('What type of extension would you like to create?')

        capture_io do
          ask(type: nil)
        end
      end

      def test_accepts_the_api_key_to_associate_with_extension
        form = ask
        orgs = ShopifyCli::Helpers::Organizations.fetch_with_app(@context)
        assert_equal form.app['apiKey'], orgs.first['apps'].first['apiKey']
      end

      def test_prompts_the_user_to_choose_an_app_to_associate_with_extension_if_no_app_is_provided
        CLI::UI::Prompt.expects(:ask).with('Which app would you like to associate with the extension?')

        capture_io do
          ask(api_key: nil)
        end
      end

      def test_fails_with_invalid_api_key_to_associate_with_extension
        io = capture_io do
          ask(api_key: '00001')
        end

        assert_match('The api key does not match any of the existing apps', io.join)
      end

      private

      def ask(title: ['test-extension'], type: 'product-details', api_key: '1234')
        Create.ask(
          @context,
          [],
          title: title,
          type: type,
          api_key: api_key,
        )
      end
    end
  end
end
