# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    module Converters
      class RegistrationConverterTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)

          @registration_id = 42
          @registration_uuid = "123"
          @fake_type = "TEST_EXTENSION"
          @fake_title = "Fake Title"
          @fake_extension_context = "fake_context"
          @last_user_interaction_at = Time.now.to_s
        end

        def test_from_hash_aborts_with_a_parse_error_if_the_hash_is_nil
          io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
            Converters::RegistrationConverter.from_hash(@context, nil)
          end

          assert_message_output(io: io, expected_content: @context.message("tasks.errors.parse_error"))
        end

        def test_from_hash_parses_registration_from_a_hash
          hash = {
            Converters::RegistrationConverter::ID_FIELD => @registration_id,
            Converters::RegistrationConverter::UUID_FIELD => @registration_uuid,
            Converters::RegistrationConverter::TYPE_FIELD => @fake_type,
            Converters::RegistrationConverter::TITLE_FIELD => @fake_title,
            Converters::RegistrationConverter::DRAFT_VERSION_FIELD => {
              Converters::VersionConverter::REGISTRATION_ID_FIELD => @registration_id,
              Converters::VersionConverter::LAST_USER_INTERACTION_AT_FIELD => @last_user_interaction_at,
            },
          }

          parsed_registration = Converters::RegistrationConverter.from_hash(@context, hash)

          assert_kind_of(Models::Registration, parsed_registration)
          assert_equal @registration_id, parsed_registration.id
          assert_equal @registration_uuid, parsed_registration.uuid
          assert_equal @fake_type, parsed_registration.type
          assert_equal @fake_title, parsed_registration.title
          assert_equal @registration_id, parsed_registration.draft_version.registration_id
          assert_kind_of(Time, parsed_registration.draft_version.last_user_interaction_at)
        end
      end
    end
  end
end
