# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    module Converters
      class VersionConverterTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)

          @api_key = "FAKE_API_KEY"
          @registration_id = 42
          @config = {}
          @extension_context = "fake#context"
          @location = "https://www.fakeurl.com"
          @last_user_interaction_at = Time.now.to_s
        end

        def test_from_hash_aborts_with_a_parse_error_if_the_hash_is_nil
          io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
            Converters::VersionConverter.from_hash(@context, nil)
          end

          assert_message_output(io: io, expected_content: @context.message("tasks.errors.parse_error"))
        end

        def test_from_hash_parses_a_version_from_a_hash
          hash = {
            Converters::VersionConverter::REGISTRATION_ID_FIELD => @registration_id,
            Converters::VersionConverter::LAST_USER_INTERACTION_AT_FIELD => @last_user_interaction_at,
            Converters::VersionConverter::CONTEXT_FIELD => @extension_context,
            Converters::VersionConverter::LOCATION_FIELD => @location,
            Converters::VersionConverter::VALIDATION_ERRORS_FIELD => [],
          }

          parsed_version = Tasks::Converters::VersionConverter.from_hash(@context, hash)

          assert_kind_of(Models::Version, parsed_version)
          assert_equal @registration_id, parsed_version.registration_id
          assert_kind_of(Time, parsed_version.last_user_interaction_at)
          assert_equal @extension_context, parsed_version.context
          assert_equal @location, parsed_version.location
          assert_equal [], parsed_version.validation_errors
        end
      end
    end
  end
end
