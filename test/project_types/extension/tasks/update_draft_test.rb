# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Tasks
    class UpdateDraftTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::UpdateDraft

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @api_key = 'FAKE_API_KEY'
        @registration_id = 42
        @config = { }
        @extension_context = 'fake#context'

        @input = {
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          extension_context: @extension_context
        }
      end

      def test_parses_a_version_from_the_graphql_response
        stub_update_draft_success(**@input)

        updated_draft = Tasks::UpdateDraft.call(
          context: @context,
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          extension_context: @extension_context
        )

        assert_kind_of Models::Version, updated_draft
        assert_equal @registration_id, updated_draft.registration_id
        assert_equal @extension_context, updated_draft.context
        assert_kind_of Time, updated_draft.last_user_interaction_at
      end

      def test_aborts_with_parse_error_if_no_updated_version_or_errors_are_returned
        stub_update_draft_failure(errors: [], **@input)

        error = assert_raises(ShopifyCli::Abort) do
          Tasks::UpdateDraft.call(
            context: @context,
            api_key: @api_key,
            registration_id: @registration_id,
            config: @config,
            extension_context: @extension_context
          )
        end

        assert_match Tasks::UpdateDraft::PARSE_ERROR, error.message
      end

      def test_aborts_with_errors_if_user_errors_are_returned
        user_errors = [ {field: ['field'], UserErrors::MESSAGE_FIELD => 'An error occurred on field'} ]
        stub_update_draft_failure(errors: user_errors, **@input)

        error = assert_raises(ShopifyCli::Abort) do
          Tasks::UpdateDraft.call(
            context: @context,
            api_key: @api_key,
            registration_id: @registration_id,
            config: @config,
            extension_context: @extension_context
          )
        end

        assert_match 'An error occurred on field', error.message
      end
    end
  end
end
