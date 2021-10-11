require "test_helper"

module ShopifyCLI
  class ReportingConfigurationControllerTest < MiniTest::Test
    def setup
      super
      @context = TestHelpers::FakeContext.new
    end

    def test_can_send_returns_false_when_the_environment_is_development
      # Given
      ShopifyCLI::Environment.expects(:development?).returns(true)

      # When
      got = ReportingConfigurationController.check_or_prompt_report_automatically(context: @context)

      # Then
      refute got
    end

    def test_can_send_returns_false_when_the_environment_is_test
      # Given
      ShopifyCLI::Environment.expects(:development?).returns(false)
      ShopifyCLI::Environment.expects(:test?).returns(true)

      # When
      got = ReportingConfigurationController.check_or_prompt_report_automatically(context: @context)

      # Then
      refute got
    end

    def test_can_send_returns_false_when_the_environment_is_not_interactive
      # Given
      ShopifyCLI::Environment.expects(:test?).returns(false)
      ShopifyCLI::Environment.expects(:development?).returns(false)
      ShopifyCLI::Environment.expects(:interactive?).returns(false)

      # When
      got = ReportingConfigurationController.check_or_prompt_report_automatically(context: @context)

      # Then
      refute got
    end

    def test_can_send_returns_true_when_the_user_was_already_prompted_and_they_enabled_it
      # Given
      ShopifyCLI::Environment.expects(:test?).returns(false)
      ShopifyCLI::Environment.expects(:development?).returns(false)
      ShopifyCLI::Environment.expects(:interactive?).returns(true)
      ShopifyCLI::Config
        .expects(:get_section)
        .with(Constants::Config::Sections::Analytics::NAME)
        .returns({ Constants::Config::Sections::Analytics::Fields::ENABLED => true })
      ShopifyCLI::Config
        .expects(:get_bool)
        .with(
          Constants::Config::Sections::Analytics::NAME,
          Constants::Config::Sections::Analytics::Fields::ENABLED,
          default: false
        )
        .returns(true)

      # When
      got = ReportingConfigurationController.check_or_prompt_report_automatically(context: @context)

      # Then
      assert got
    end

    def test_can_send_stores_and_returns_the_value_selected_by_the_user
      # Given
      ShopifyCLI::Environment.expects(:test?).returns(false)
      ShopifyCLI::Environment.expects(:development?).returns(false)
      ShopifyCLI::Environment.expects(:interactive?).returns(true)
      ShopifyCLI::Config
        .expects(:get_section)
        .with(Constants::Config::Sections::Analytics::NAME)
        .returns({})

      ShopifyCLI::Config
        .expects(:set)
        .with(
          Constants::Config::Sections::Analytics::NAME,
          Constants::Config::Sections::Analytics::Fields::ENABLED,
          false
        )
      CLI::UI::Prompt.expects(:ask).returns(false)

      # When
      got = ReportingConfigurationController.check_or_prompt_report_automatically(context: @context)

      # Then
      refute got
    end
  end
end
