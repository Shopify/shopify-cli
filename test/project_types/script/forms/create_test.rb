# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        ShopifyCLI::ProjectType.load_type(:script)
        @context = TestHelpers::FakeContext.new
      end

      def test_returns_all_defined_attributes_if_valid
        title = "title"
        extension_point = "discount"
        form = ask(title: title, extension_point: extension_point)
        assert_equal(form.title, title)
        assert_equal(form.extension_point, extension_point)
      end

      def test_asks_extension_point_if_no_flag
        eps = ["discount", "another"]
        Layers::Application::ExtensionPoints.expects(:available_types).returns(eps)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message("script.forms.create.select_extension_point"),
          options: eps
        )
        ask(title: "title")
      end

      def test_asks_title_if_no_flag
        title = "title"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_title")).returns(title)
        form = ask(extension_point: "discount")
        assert_equal title, form.title
      end

      def test_title_is_cleaned_after_prompt
        title = "title with space"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_title")).returns(title)
        form = ask(extension_point: "discount")
        assert_equal "title_with_space", form.title
      end

      def test_title_is_cleaned_when_using_flag
        form = ask(title: "title with space", extension_point: "discount")
        assert_equal "title_with_space", form.title
      end

      def test_invalid_title
        title = "na/me"
        CLI::UI::Prompt.expects(:ask).returns(title)

        assert_raises(Script::Errors::InvalidScriptTitleError) { ask }
      end

      def test_invalid_title_as_option
        assert_raises(Script::Errors::InvalidScriptTitleError) do
          ask(title: "na/me")
        end
      end

      private

      def ask(title: nil, extension_point: nil)
        Create.ask(
          @context,
          [],
          title: title,
          extension_point: extension_point
        )
      end
    end
  end
end
