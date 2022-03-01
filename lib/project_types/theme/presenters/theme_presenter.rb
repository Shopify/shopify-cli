# frozen_string_literal: true

require "forwardable"

module Theme
  module Presenters
    class ThemePresenter
      extend Forwardable

      COLOR_BY_ROLE = {
        "live" => "green",
        "unpublished" => "yellow",
        "development" => "blue",
      }

      attr_reader :theme

      def_delegators :theme, :id, :name, :role

      def initialize(theme)
        @theme = theme
      end

      def to_s(mode = :long)
        case mode
        when :short
          "{{bold:#{name} #{theme_tags}}}"
        when :long
          "{{green:##{id}}} {{bold:#{name} #{theme_tags}}}"
        else
          inspect
        end
      end

      private

      def theme_tags
        tags = ["{{#{tag_color}:[#{role}]}}"]
        tags << "{{cyan:[yours]}}}}" if theme.current_development?
        tags.join(" ")
      end

      def tag_color
        COLOR_BY_ROLE[role] || "italic"
      end
    end
  end
end
