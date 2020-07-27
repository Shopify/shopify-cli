# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Forms
    class CreateTest < MiniTest::Test
      def test_returns_all_defined_attributes_if_valid
        form = ask
        assert_equal(form.store, 'shop.myshopify.com')
        assert_equal(form.password, 'boop')
        assert_equal(form.title, 'My Theme')
        assert_equal(form.name, 'my_theme')
      end

      def test_store_can_be_provided_by_flag
        form = ask(store: 'shop.myshopify.com')
        assert_equal(form.store, 'shop.myshopify.com')
      end

      def test_store_is_prompted
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message('theme.forms.create.ask_store'), allow_empty: false)
          .returns('shop.myshopify.com')
        ask(store: nil)
      end

      def test_password_can_be_provided_by_flag
        form = ask(password: 'boop')
        assert_equal(form.password, 'boop')
      end

      def test_password_is_prompted
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.create.ask_password'), allow_empty: false)
          .returns('boop')
        ask(password: nil)
      end

      def test_title_can_be_provided_by_flag
        form = ask(title: 'My Theme')
        assert_equal(form.name, 'my_theme')
        assert_equal(form.title, 'My Theme')
      end

      def test_title_is_prompted
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.create.ask_title'), allow_empty: false)
          .returns('My Theme')
        assert_equal(ask.name, 'my_theme')
        ask(title: nil)
      end

      def test_aborts_if_field_empty
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.create.ask_store'), allow_empty: false)
          .returns(' ')
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.create.ask_password'), allow_empty: false)
          .returns(' ')
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.create.ask_title'), allow_empty: false)
          .returns(' ')
        @context.expects(:abort)
          .with(@context.message('theme.forms.create.errors', 'store, password, title'.capitalize))

        ask(store: nil, password: nil, title: nil)
      end

      private

      def ask(title: 'My Theme', password: 'boop', store: 'shop.myshopify.com')
        Create.ask(
          @context,
          [],
          title: title,
          password: password,
          store: store
        )
      end
    end
  end
end
