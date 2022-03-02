# frozen_string_literal: true

require_relative "filter/path_matcher"

module ShopifyCLI
  module Theme
    class IncludeFilter
      include Filter::PathMatcher

      attr_reader :globs, :regexes

      def initialize(root, patterns = [])
        @root = Pathname.new(root)
        @patterns = patterns.nil? ? [] : patterns.compact.reject(&:empty?)

        regexes, globs = patterns_to_regexes_and_globs(@patterns)

        @regexes = regexes
        @globs = globs
      end

      def match?(path)
        return true unless present?(@patterns)

        path = path.to_s
        return true if path.empty?

        path = @root.join(path).to_s

        regexes.each do |regex|
          return true if regex_match?(regex, path)
        end

        globs.each do |glob|
          return true if glob_match?(glob, path)
        end

        false
      end

      private

      def present?(patterns)
        !patterns.nil? && !patterns.empty?
      end

      # Take in string patterns and convert them to either
      # regex patterns or glob patterns so that they are handled in an expected manner.
      def patterns_to_regexes_and_globs(patterns)
        new_regexes = []
        new_globs = []

        patterns
          .map(&:strip)
          .each do |pattern|
            if regex?(pattern)
              new_regexes << as_regex(pattern)
            else
              new_globs << as_glob(pattern)
            end
          end

        [new_regexes, new_globs]
      end
    end
  end
end
