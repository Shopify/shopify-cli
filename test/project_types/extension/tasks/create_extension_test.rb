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
        @fake_config = {
          field: 'with stuff'
        }
        @fake_extension_context = 'fake_context'

        @input = {
          api_key: @api_key,
          type: @fake_type,
          title: @fake_title,
          config: @fake_config,
          extension_context: @fake_extension_context
        }
      end

      def test_parses_registration_from_the_graphql_response
        stub_create_extension_success(**@input)

        created_registration = Tasks::CreateExtension.call(
          context: @context,
          api_key: @api_key,
          type: @fake_type,
          title: @fake_title,
          config: @fake_config,
          extension_context: @fake_extension_context
        )

        assert_kind_of Models::Registration, created_registration
        assert_equal @fake_type, created_registration.type
        assert_equal @fake_title, created_registration.title
        assert_kind_of Time, created_registration.draft_version.last_user_interaction_at
      end

      def test_aborts_with_parse_error_if_no_created_registration_or_errors_are_returned
        stub_create_extension_failure(userErrors: [], **@input)

        error = assert_raises(ShopifyCli::Abort) do
          Tasks::CreateExtension.call(
            context: @context,
            api_key: @api_key,
            type: @fake_type,
            title: @fake_title,
            config: @fake_config,
            extension_context: @fake_extension_context
          )
        end

        assert_match Tasks::UpdateDraft::PARSE_ERROR, error.message
      end

      def test_aborts_with_errors_if_user_errors_are_returned
        user_errors = [ {field: ['field'], UserErrors::MESSAGE_FIELD => 'An error occurred on field'} ]
        stub_create_extension_failure(userErrors: user_errors, **@input)

        error = assert_raises(ShopifyCli::Abort) do
          Tasks::CreateExtension.call(
            context: @context,
            api_key: @api_key,
            type: @fake_type,
            title: @fake_title,
            config: @fake_config,
            extension_context: @fake_extension_context
          )
        end

        assert_match 'An error occurred on field', error.message
      end
    end
  end
end
