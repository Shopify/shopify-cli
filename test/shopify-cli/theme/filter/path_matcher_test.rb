# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/filter/path_matcher"

module ShopifyCLI
  module Theme
    module Filter
      class PathMatcherTest < Minitest::Test
        include PathMatcher

        def test_regex_match_when_it_matches
          assert regex_match?(/my_file/, "my_file")
        end

        def test_regex_match_when_it_does_not_match
          refute regex_match?(/my_file/, "other_file")
        end

        def test_glob_match_when_it_matches
          glob = "*build/*"
          path = "templates/build/hello/world"

          assert glob_match?(glob, path)
        end

        def test_glob_match_when_it_does_not_match
          glob = "*build/*"
          path = "templates/world.gif"

          refute glob_match?(glob, path)
        end

        def test_regex_when_it_is_a_regex
          assert regex?("/file.liquid/")
        end

        def test_regex_when_it_is_not_a_regex
          refute regex?("*build*")
        end

        def test_as_regex
          assert_equal(/file.liquid/, as_regex("/file.liquid/"))
        end

        def test_as_glob
          assert_equal "*build/*", as_glob("build/")
        end
      end
    end
  end
end
