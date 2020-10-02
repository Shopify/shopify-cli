# frozen_string_literal: true
require 'project_types/theme/test_helper'

module Theme
  module Forms
    class PullTest < MiniTest::Test
      def test_returns_all_defined_attributes_if_valid
        query_themes
        form = ask
        assert_equal(form.store, 'shop.myshopify.com')
        assert_equal(form.password, 'boop')
        assert_equal(form.themeid, '2468')
        assert_equal(form.name, 'my_theme')
      end

      def test_env_can_be_provided_by_flag
        query_themes
        form = ask(env: 'development')
        assert_equal(form.env, 'development')
      end

      def test_env_nil_if_not_provided
        query_themes
        form = ask
        assert_nil(form.env)
      end

      def test_store_can_be_provided_by_flag
        query_themes
        form = ask(store: 'shop.myshopify.com')
        assert_equal(form.store, 'shop.myshopify.com')
      end

      def test_store_is_prompted
        query_themes
        CLI::UI::Prompt.expects(:ask)
          .with(@context.message('theme.forms.ask_store'), allow_empty: false)
          .returns('shop.myshopify.com')
        ask(store: nil)
      end

      def test_password_can_be_provided_by_flag
        query_themes
        form = ask(password: 'boop')
        assert_equal(form.password, 'boop')
      end

      def test_password_is_prompted
        query_themes
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.ask_password'), allow_empty: false)
          .returns('boop')
        ask(password: nil)
      end

      def test_aborts_if_field_empty
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.ask_store'), allow_empty: false)
          .returns(' ')
        CLI::UI::Prompt.expects(:ask).with(@context.message('theme.forms.ask_password'), allow_empty: false)
          .returns(' ')

        assert_nil(ask(store: nil, password: nil, themeid: nil))
      end

      private

      def ask(password: 'boop', store: 'shop.myshopify.com', themeid: '2468', env: nil)
        Pull.ask(
          @context,
          [],
          password: password,
          store: store,
          themeid: themeid,
          env: env
        )
      end

      def query_themes
        resp = [200,
                { "themes" =>
                   [{ "id" => 2468,
                      "name" => "my_theme" },
                    { "id" => 1357,
                      "name" => "your_theme" }] }]

        ShopifyCli::AdminAPI.expects(:rest_request)
          .with(@context,
                shop: 'shop.myshopify.com',
                token: 'boop',
                path: 'themes.json')
          .returns(resp)

        @themes = resp[1]['themes'].map { |theme| [theme['name'], theme['id']] }.to_h
      end
    end
  end
end
