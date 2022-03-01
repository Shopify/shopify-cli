# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/presenters/theme_presenter"

module Theme
  module Presenters
    class ThemePresenterTest < MiniTest::Test
      def test_to_s
        expected = "{{green:#1234}} {{bold:My test theme {{yellow:[unpublished]}}}}"
        actual = presenter.to_s

        assert_equal(expected, actual)
      end

      def test_to_s_with_mode_short
        expected = "{{bold:My test theme {{yellow:[unpublished]}}}}"
        actual = presenter.to_s(:short)

        assert_equal(expected, actual)
      end

      def test_to_s_with_live_theme
        expected = "{{green:#1234}} {{bold:My test theme {{green:[live]}}}}"
        actual = live_presenter.to_s

        assert_equal(expected, actual)
      end

      def test_to_s_with_development_theme
        expected = "{{green:#1234}} {{bold:My test theme {{blue:[development]}} {{cyan:[yours]}}}}}}"
        actual = development_presenter.to_s

        assert_equal(expected, actual)
      end

      def test_theme_delegators
        assert_equal(1234, presenter.id)
        assert_equal("My test theme", presenter.name)
        assert_equal("unpublished", presenter.role)
      end

      private

      def live_presenter
        live_theme = theme(role: "live")
        ThemePresenter.new(live_theme)
      end

      def development_presenter
        development_theme = theme(role: "development", current_development?: true)
        ThemePresenter.new(development_theme)
      end

      def presenter
        ThemePresenter.new(theme)
      end

      def theme(options = {})
        stub({
          id: 1234,
          name: "My test theme",
          shop: "test.myshopify.io",
          role: "unpublished",
          editor_url: "https://test.myshopify.io/editor",
          preview_url: "https://test.myshopify.io/preview",
          current_development?: false,
          live?: false,
          **options,
        })
      end
    end
  end
end
