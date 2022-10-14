# frozen_string_literal: true

require_relative "theme_presenter"

module Theme
  module Presenters
    class ThemesPresenter
      SUPPORTED_ROLES = %w(live unpublished development)

      def initialize(ctx, root)
        @ctx = ctx
        @root = root
      end

      def all
        all_themes
          .select { |theme| SUPPORTED_ROLES.include?(theme.role) }
          .sort_by { |theme| SUPPORTED_ROLES.index(theme.role) }
          .map { |theme| ThemePresenter.new(theme) }
      end

      private

      def all_themes
        ShopifyCLI::Theme::Theme.all(@ctx, root: @root)
      end
    end
  end
end
