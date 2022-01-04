# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Tasks
    module Converters
      class ValidationErrorConverterTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_from_hash_returns_empty_array_if_errors_are_nil
          assert_equal [], ValidationErrorConverter.from_array(@context, nil)
        end

        def test_from_hash_aborts_with_parse_error_if_errors_are_not_an_array_and_not_nil
          io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
            ValidationErrorConverter.from_array(@context, Object)
          end

          assert_message_output(io: io, expected_content: [
            @context.message("tasks.errors.parse_error"),
          ])
        end

        def test_from_hash_returns_parsed_validation_errors_if_valid
          fields = %w(config name)
          message = "error message"

          errors = [{ "field" => fields, "message" => message }]
          parsed_validation_errors = ValidationErrorConverter.from_array(@context, errors)

          assert_equal 1, parsed_validation_errors.count
          assert_equal fields, parsed_validation_errors.first.field
          assert_equal message, parsed_validation_errors.first.message
        end

        def test_from_hash_returns_all_parsed_validation_errors_if_valid
          message = "error message"
          message2 = "error message 2"

          errors = [
            { "field" => %w(field1), "message" => message },
            { "field" => %w(config name), "message" => message2 },
          ]
          parsed_validation_messages = ValidationErrorConverter.from_array(@context, errors).map(&:message)

          assert_equal [message, message2], parsed_validation_messages
        end
      end
    end
  end
end
