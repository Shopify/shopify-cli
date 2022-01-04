# typed: ignore
require "test_helper"

module Extension
  module Forms
    module Questions
      class AskTemplateTest < MiniTest::Test
        include TestHelpers

        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_does_not_prompt_for_template_when_not_required
          mock_environment_settings(shopifolk: false, extension_server_beta: false)
          project_details = OpenStruct.new(
            type: OpenStruct.new(
              identifier: "THEME_APP_EXTENSION",
            )
          )

          AskTemplate.new(ctx: context).call(project_details).tap do |result|
            assert_equal(project_details, result.value)
          end
        end

        def test_prompts_for_template_when_required
          mock_environment_settings
          project_details = OpenStruct.new(
            type: OpenStruct.new(
              identifier: "CHECKOUT_UI_EXTENSION",
            )
          )

          CLI::UI::Prompt.expects(:ask).returns("javascript")

          AskTemplate.new(ctx: context).call(project_details).tap do
            assert_equal("javascript", project_details.template)
          end
        end

        def test_ctx_is_the_only_required_configuration_option
          assert_nothing_raised { AskTemplate.new(ctx: FakeContext.new) }
        end

        def test_user_provided_template_is_chosen_over_interactive_option
          mock_environment_settings
          project_details = OpenStruct.new(
            type: OpenStruct.new(
              identifier: "CHECKOUT_UI_EXTENSION",
            )
          )

          AskTemplate.new(ctx: context, template: "typescript").call(project_details).tap do
            assert_equal("typescript", project_details.template)
          end
        end

        private

        def context
          FakeContext.new
        end

        def mock_environment_settings(shopifolk: true, extension_server_beta: true)
          ShopifyCLI::Shopifolk.stubs(:check).returns(shopifolk)
          ShopifyCLI::Feature.stubs(:enabled?).with(:extension_server_beta).returns(extension_server_beta)
        end
      end
    end
  end
end
