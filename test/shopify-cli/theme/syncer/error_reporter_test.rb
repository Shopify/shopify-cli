# frozen_string_literal: true

require "test_helper"
require "shopify_cli/theme/syncer"

module ShopifyCLI
  module Theme
    class Syncer
      class ErrorReporterTest < Minitest::Test
        def setup
          super
          @error_reporter = ErrorReporter.new(@context) # stub(puts: nil))
        end

        def test_report_errors_with_standard_errors
          io = capture_io do
            @error_reporter.report_error("error 1")
            @error_reporter.report_error("error 2")
          end

          io_messages = io.join

          assert_match("error 1", io_messages)
          assert_match("error 2", io_messages)
        end

        def test_report_errors_with_delayed_errors
          @error_reporter.delay_errors!

          before_report_errors = capture_io do
            @error_reporter.report_error("error 1")
            @error_reporter.report_error("error 2")
          end

          after_report_errors = capture_io do
            @error_reporter.report_errors!
          end

          before_report_io = before_report_errors.join
          after_report_io = after_report_errors.join

          assert_empty(before_report_io)
          refute_empty(after_report_io)
          assert_match("error 1", after_report_io)
          assert_match("error 2", after_report_io)
        end

        def test_has_any_error_when_no_error_was_reported
          refute(@error_reporter.has_any_error?)
        end

        def test_has_any_error_when_an_error_was_reported
          @error_reporter.report_error("error 1")
          assert(@error_reporter.has_any_error?)
        end
      end
    end
  end
end
