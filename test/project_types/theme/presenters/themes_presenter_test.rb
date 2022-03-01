# frozen_string_literal: true

require "project_types/theme/test_helper"
require "project_types/theme/presenters/themes_presenter"
require "shopify_cli/theme/theme"

module Theme
  module Presenters
    class ThemesPresenterTest < MiniTest::Test
      def test_all
        ShopifyCLI::Theme::Theme
          .expects(:all)
          .with(ctx, root: root)
          .returns([
            theme(0, role: "live"),
            theme(1, role: "unpublished"),
            theme(2, role: "development"),
            theme(3, role: "unpublished"),
            theme(4, role: "other"),
            theme(5, role: "live"),
            theme(6, role: "development"),
          ])

        presenter = ThemesPresenter.new(ctx, root)

        actual_presenters = presenter.all.map(&:to_s)

        assert_equal(7, actual_presenters.size)
        assert_match(/Theme.*\[live\]/, actual_presenters[0])
        assert_match(/Theme.*\[live\]/, actual_presenters[1])
        assert_match(/Theme.*\[unpublished\]/, actual_presenters[2])
        assert_match(/Theme.*\[unpublished\]/, actual_presenters[3])
        assert_match(/Theme.*\[development\]/, actual_presenters[4])
        assert_match(/Theme.*\[development\]/, actual_presenters[5])
        assert_match(/Theme.*\[other\]/, actual_presenters[6])
      end

      private

      def theme(id, attributes = {})
        stub(id: id, name: "Theme #{id}", current_development?: false, **attributes)
      end

      def ctx
        @ctx ||= ShopifyCLI::Context.new
      end

      def root
        @root ||= "."
      end
    end
  end
end
