# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    class UpdateDraftTest < MiniTest::Test
      include TestHelpers::FakeUI
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::UpdateDraft

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @api_key = "FAKE_API_KEY"
        @registration_id = 42
        @config = {}
        @extension_context = "fake#context"
        @location = "https://www.fakeurl.com"

        @input = {
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          extension_context: @extension_context,
        }
      end

      def test_returns_the_updated_draft_if_no_errors_occurred
        stub_update_draft_success(**@input)

        updated_draft = Tasks::UpdateDraft.call(
          context: @context,
          api_key: @api_key,
          registration_id: @registration_id,
          config: @config,
          extension_context: @extension_context,
        )

        assert_kind_of(Models::Version, updated_draft)
        assert_equal @registration_id, updated_draft.registration_id
      end

      def test_aborts_with_parse_error_if_no_updated_version_or_errors_are_returned
        stub_update_draft_failure(errors: [], **@input)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          Tasks::UpdateDraft.call(
            context: @context,
            api_key: @api_key,
            registration_id: @registration_id,
            config: @config,
            extension_context: @extension_context,
          )
        end

        assert_message_output(io: io, expected_content: @context.message("tasks.errors.parse_error"))
      end

      def test_aborts_with_errors_if_user_errors_are_returned
        user_errors = [{ field: ["field"], UserErrors::MESSAGE_FIELD => "An error occurred on field" }]
        stub_update_draft_failure(errors: user_errors, **@input)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          Tasks::UpdateDraft.call(
            context: @context,
            api_key: @api_key,
            registration_id: @registration_id,
            config: @config,
            extension_context: @extension_context,
          )
        end

        assert_message_output(io: io, expected_content: "An error occurred on field")
      end
    end
  end
end
