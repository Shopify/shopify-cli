# frozen_string_literal: true

require_relative "theme_presenter"

module Theme
  module Presenters
    class ThemesPresenter
      ORDER_BY_ROLE = %w(live unpublished development)

      def initialize(ctx, root)
        @ctx = ctx
        @root = root
      end

      def all
        all_themes
          .sort_by { |theme| order_by_role(theme) }
          .map { |theme| ThemePresenter.new(theme) }
      end

      private

      def order_by_role(theme)
        ORDER_BY_ROLE.index(theme.role) || ORDER_BY_ROLE.size
      end

      def all_themes
        ShopifyCLI::Theme::Theme.all(@ctx, root: @root)
      end
    end
  end
end
