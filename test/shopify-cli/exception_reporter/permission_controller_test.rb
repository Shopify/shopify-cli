require "test_helper"

module ShopifyCLI
  module ExceptionReporter
    class PermissionControllerTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
      end

      def test_can_send_returns_false_when_the_environment_is_not_interactive
        # Given
        ShopifyCLI::Environment.expects(:interactive?).returns(false)

        # When
        got = PermissionController.can_report_automatically?(context: @context)

        # Then
        refute got
      end

      def test_can_send_returns_true_when_the_user_was_already_prompted_and_they_enabled_it
        # Given
        ShopifyCLI::Environment.expects(:interactive?).returns(true)
        ShopifyCLI::Config
          .expects(:get_section)
          .with(Constants::Config::Sections::ErrorTracking::NAME)
          .returns({ Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING => true })
        ShopifyCLI::Config
          .expects(:get_bool)
          .with(
            Constants::Config::Sections::ErrorTracking::NAME,
            Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING,
            default: false
          )
          .returns(true)

        # When
        got = PermissionController.can_report_automatically?(context: @context)

        # Then
        assert got
      end

      def test_can_send_stores_and_returns_the_value_selected_by_the_user
        # Given
        ShopifyCLI::Environment.expects(:interactive?).returns(true)
        ShopifyCLI::Config
          .expects(:get_section)
          .with(Constants::Config::Sections::ErrorTracking::NAME)
          .returns({})

        ShopifyCLI::Config
          .expects(:set)
          .with(
            Constants::Config::Sections::ErrorTracking::NAME,
            Constants::Config::Sections::ErrorTracking::Fields::AUTOMATIC_REPORTING,
            false
          )
        CLI::UI::Prompt.expects(:ask).returns(false)

        # When
        got = PermissionController.can_report_automatically?(context: @context)

        # Then
        refute got
      end
    end
  end
end
