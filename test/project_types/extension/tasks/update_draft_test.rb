# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/stubs/update_draft'

module Extension
  module Tasks
    class UpdateDraftTest < MiniTest::Test
      include TestHelpers::Partners
      include Extension::Stubs::UpdateDraft

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @api_key = 'FAKE_API_KEY'
        @registration_id = 42
        @config = { }
        @extension_context = 'fake#context'
      end

      def test_parses_a_version_from_the_graphql_response
        stub_update_draft(
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          context: @extension_context
        )

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
      end

      def test_returns_nil_if_the_updated_draft_is_not_returned
        stub_update_draft_with_errors(
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          context: @extension_context
        )

        assert_nothing_raised do
          assert_nil Tasks::UpdateDraft.call(
            context: @context,
            api_key: @api_key,
            registration_id: @registration_id,
            config: @config,
            extension_context: @extension_context
          )
        end
      end
    end
  end
end
