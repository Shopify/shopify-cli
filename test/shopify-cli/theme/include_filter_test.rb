# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/include_filter"

module ShopifyCLI
  module Theme
    class IncludeFilterTest < Minitest::Test
      def test_match_when_pattern_is_nil
        assert IncludeFilter.new.match?("../file.txt")
      end

      def test_match_when_pattern_is_empty
        assert IncludeFilter.new("").match?("../file.txt")
      end

      def test_match_when_pattern_is_a_regex_and_matches
        filter = IncludeFilter.new("templates/")
        assert filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_regex_and_does_not_match
        filter = IncludeFilter.new("build/")
        refute filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_glob_and_matches
        filter = IncludeFilter.new("/\\.txt/")
        assert filter.match?("templates/test.txt")
      end

      def test_match_when_pattern_is_a_glob_and_does_not_match
        filter = IncludeFilter.new("/\\.liquid/")
        refute filter.match?("templates/test.txt")
      end
    end
  end
end
