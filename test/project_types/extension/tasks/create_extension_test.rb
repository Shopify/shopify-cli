# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Tasks
    class CreateExtensionTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::CreateExtension

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @api_key = 'FAKE_API_KEY'
        @fake_type = 'TEST_EXTENSION'
        @fake_title = 'Fake Title'
      end

      def test_parses_registration_from_the_graphql_response
        stub_create_extension(api_key: @api_key, type: @fake_type, title: @fake_title)

        created_registration = Tasks::CreateExtension.call(
          context: @context,
          api_key: @api_key,
          type: @fake_type,
          title: @fake_title
        )

        assert_kind_of Models::Registration, created_registration
        assert_equal created_registration.type, @fake_type
        assert_equal created_registration.title, @fake_title
      end

      def test_returns_nil_if_there_is_no_created_registration
        stub_create_extension_with_errors(api_key: @api_key, type: @fake_type, title: @fake_title)

        assert_nothing_raised do
          assert_nil Tasks::CreateExtension.call(
            context: @context,
            api_key: @api_key,
            type: @fake_type,
            title: @fake_title
          )
        end
      end
    end
  end
end
