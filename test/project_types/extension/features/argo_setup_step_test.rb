# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Features
    class ArgoSetupStepsTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)

        @identifier = "FAKE_ARGO_TYPE"
        @directory = "fake_directory"
        @system = ShopifyCLI::JsSystem.new(ctx: @context)
      end

      def test_always_successful_steps_return_true_no_matter_what_the_step_block_returns
        assert call_step(ArgoSetupStep.always_successful { false })
        assert call_step(ArgoSetupStep.always_successful { true })
      end

      def test_default_steps_return_what_the_step_block_returns
        refute call_step(ArgoSetupStep.default { false })
        assert call_step(ArgoSetupStep.default { true })
      end

      def test_all_step_types_catch_shopify_cli_abort_exceptions_and_output_their_message_and_return_false
        always_successful_io = capture_io do
          refute call_step(ArgoSetupStep.always_successful { raise ShopifyCLI::Abort, "always_successful error" })
        end

        default_io = capture_io do
          refute call_step(ArgoSetupStep.default { raise ShopifyCLI::Abort, "default_io error" })
        end

        assert_message_output(io: always_successful_io, expected_content: "always_successful error")
        assert_message_output(io: default_io, expected_content: "default_io error")
      end

      def test_all_step_types_catch_any_exceptions_and_output_their_message_and_return_false
        always_successful_io = capture_io do
          refute call_step(ArgoSetupStep.always_successful { raise "always_successful error" })
        end

        default_io = capture_io do
          refute call_step(ArgoSetupStep.default { raise "default_io error" })
        end

        assert_message_output(io: always_successful_io, expected_content: "{{x}} always_successful error")
        assert_message_output(io: default_io, expected_content: "{{x}} default_io error")
      end

      private

      def call_step(step, context: @context, identifier: @identifier, directory_name: @directory, system: @system)
        step.call(context, identifier, directory_name, system)
      end
    end
  end
end
