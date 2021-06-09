# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Forms
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners

      def setup
        super
        ShopifyCli::ProjectType.load_type(:script)
        @context = TestHelpers::FakeContext.new
      end

      def test_returns_all_defined_attributes_if_valid
        name = "name"
        api = "discount"
        form = ask(name: name, api: api, language: "assemblyscript")
        assert_equal(form.name, name)
        assert_equal(form.api, api)
      end

      def test_asks_api_if_no_flag
        eps = ["discount", "another"]
        Layers::Application::ExtensionPoints.expects(:available_types).returns(eps)
        CLI::UI::Prompt.expects(:ask).with(
          @context.message("script.forms.create.select_api"),
          options: eps
        )
        ask(name: "name", language: "assemblyscript")
      end

      def test_asks_name_if_no_flag
        name = "name"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_name")).returns(name)
        form = ask(api: "discount", language: "assemblyscript")
        assert_equal name, form.name
      end

      def test_name_is_cleaned_after_prompt
        name = "name with space"
        CLI::UI::Prompt.expects(:ask).with(@context.message("script.forms.create.script_name")).returns(name)
        form = ask(api: "discount", language: "assemblyscript")
        assert_equal "name_with_space", form.name
      end

      def test_name_is_cleaned_when_using_flag
        form = ask(name: "name with space", api: "discount", language: "assemblyscript")
        assert_equal "name_with_space", form.name
      end

      def test_invalid_name
        name = "na/me"
        CLI::UI::Prompt.expects(:ask).returns(name)

        assert_raises(Script::Errors::InvalidScriptNameError) { ask }
      end

      def test_invalid_name_as_option
        assert_raises(Script::Errors::InvalidScriptNameError) do
          ask(name: "na/me", language: "assemblyscript")
        end
      end

      def test_auto_selects_existing_language_if_only_one_exists
        language = "assemblyscript"
        Layers::Application::ExtensionPoints.expects(:languages).returns(%w(assemblyscript))
        CLI::UI::Prompt.expects(:ask).never
        form = ask(name: "name", api: "discount")
        assert_equal language, form.language
      end

      def test_prompts_for_language_when_multiple_options_exist_and_no_flag_passed
        language = "rust"
        all_languages = %w(assemblyscript rust)
        Layers::Application::ExtensionPoints.expects(:languages).returns(all_languages)
        CLI::UI::Prompt
          .expects(:ask)
          .with(@context.message("script.forms.create.select_language"), options: all_languages)
          .returns(language)
        form = ask(name: "name", api: "discount")
        assert_equal language, form.language
      end

      def test_succeeds_when_requested_language_is_capitalized
        language = "AssemblyScript"
        form = ask(name: "name", api: "discount", language: language)
        assert_equal language.downcase, form.language
      end

      private

      def ask(name: nil, api: nil, language: nil)
        Create.ask(
          @context,
          [],
          name: name,
          api: api,
          language: language
        )
      end
    end
  end
end
