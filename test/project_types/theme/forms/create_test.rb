# frozen_string_literal: true
require "project_types/theme/test_helper"

module Theme
  module Forms
    class CreateTest < MiniTest::Test
      def test_returns_all_defined_attributes_if_valid
        form = ask
        assert_equal("My Theme", form.title)
        assert_equal("my_theme", form.name)
      end

      def test_env_can_be_provided_by_flag
        form = ask(env: "test")
        assert_equal("test", form.env)
      end

      def test_env_nil_if_not_provided
        form = ask
        assert_nil(form.env)
      end

      def test_title_can_be_provided_by_flag
        form = ask(title: "My Theme")
        assert_equal("my_theme", form.name)
        assert_equal("My Theme", form.title)
      end

      def test_title_is_prompted
        CLI::UI::Prompt.expects(:ask).with(@context.message("theme.forms.create.ask_title"), allow_empty: false)
          .returns("My Theme")
        assert_equal("my_theme", ask.name)
        ask(title: nil)
      end

      def test_aborts_if_field_empty
        CLI::UI::Prompt.expects(:ask).with(@context.message("theme.forms.create.ask_title"), allow_empty: false)
          .returns(" ")
        @context.expects(:abort)
          .with(@context.message("theme.forms.errors", "title".capitalize))

        ask(title: nil)
      end

      private

      def ask(title: "My Theme", env: nil)
        Create.ask(
          @context,
          [],
          title: title,
          env: env
        )
      end
    end
  end
end
