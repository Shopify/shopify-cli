# typed: ignore
# frozen_string_literal: true
require "test_helper"

module Extension
  module Tasks
    class UserErrorsTest < MiniTest::Test
      include TestHelpers::FakeUI

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @test_user_errors = Object.new.extend(Tasks::UserErrors)
      end

      def test_does_not_output_or_abort_if_no_user_errors_are_present
        @context.expects(:puts).never
        @context.expects(:abort).never

        @test_user_errors.abort_if_user_errors(@context, {})
        @test_user_errors.abort_if_user_errors(@context, { UserErrors::USER_ERRORS_FIELD => [] })
        @test_user_errors.abort_if_user_errors(@context, nil)
      end

      def test_aborts_with_message_if_only_one_user_error_present
        fake_response = {
          UserErrors::USER_ERRORS_FIELD => [
            { field: ["field"], UserErrors::MESSAGE_FIELD => "An error has occurred." },
          ],
        }

        @context.expects(:abort).with("An error has occurred.").once
        @test_user_errors.abort_if_user_errors(@context, fake_response)
      end

      def test_no_matter_how_many_errors_only_last_error_calls_abort
        fake_errors = Array.new(6, { field: ["field"], UserErrors::MESSAGE_FIELD => "An error has occurred." })
        fake_errors << { field: ["field2"], UserErrors::MESSAGE_FIELD => "Last error abort." }
        fake_response = { UserErrors::USER_ERRORS_FIELD => fake_errors }

        @context.expects(:puts).with("{{x}} An error has occurred.").times(6)
        @context.expects(:abort).with("Last error abort.").once

        @test_user_errors.abort_if_user_errors(@context, fake_response)
      end

      def test_aborts_with_parse_error_message_if_user_errors_parsing_fails
        fake_response = {
          UserErrors::USER_ERRORS_FIELD => [
            { field: ["field"], wrong_message_field: "An error has occurred." },
          ],
        }

        @context.expects(:abort).with(UserErrors::USER_ERRORS_PARSE_ERROR).once
        @test_user_errors.abort_if_user_errors(@context, fake_response)
      end
    end
  end
end
