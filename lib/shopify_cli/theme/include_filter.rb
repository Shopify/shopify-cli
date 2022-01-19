# frozen_string_literal: true

require_relative "filter/path_matcher"

module ShopifyCLI
  module Theme
    class IncludeFilter
      include Filter::PathMatcher

      def initialize(pattern = nil)
        @pattern = pattern
      end

      def match?(path)
        return true unless present?(@pattern)

        if regex_pattern?
          regex_match?(regex_pattern, path)
        else
          glob_match?(glob_pattern, path)
        end
      end

      private

      def present?(pattern)
        !pattern.nil? && !pattern.empty?
      end

      def regex_pattern?
        @is_regex_pattern ||= regex?(@pattern)
      end

      def regex_pattern
        @regex_pattern ||= as_regex(@pattern)
      end

      def glob_pattern
        @glob_pattern ||= as_glob(@pattern)
      end
    end
  end
end
