# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/ignore_filter"

module ShopifyCLI
  module Theme
    class IgnoreFilterTest < Minitest::Test
      def test_new_filter
        filter = IgnoreFilter.new("/tmp")

        assert_equal("/tmp", filter.root)
        assert_equal(IgnoreFilter::DEFAULT_REGEXES, filter.regexes)
        assert_equal(IgnoreFilter::DEFAULT_GLOBS, filter.globs)
      end

      def test_filter_match
        tests = [
          { pattern: "*test.txt", input: "templates/test.txt", matches: true },
          { pattern: "*test.txt", input: "templates/foo/test.txt", matches: true },
          { pattern: "*test.txt", input: "/tmp/templates/foo/test.txt", matches: true },
          { pattern: "*build/*", input: "templates/build/hello/world", matches: true },
          { pattern: "*.json", input: "templates/settings.json", matches: true },
          { pattern: "*.gif", input: "templates/world.gif", matches: true },
          { pattern: "*.gif", input: "templates/worldgifno", matches: false },
          { pattern: "/\\.bat/", input: "templates/hello.bat", matches: true },
          { pattern: "/\\.bat/", input: "templates/hellobatno", matches: false },
          { pattern: "/\\.bat/", input: "templates/hello.css", matches: false },
          { pattern: "*test.txt", input: "/not/in/project/test.txt", matches: true },
          { pattern: "*test.txt", input: "test.txt", matches: true },
          { input: "", matches: true },
        ]

        tests.each do |testcase|
          patterns = testcase[:pattern] ? [testcase[:pattern]] : []
          filter = IgnoreFilter.new("/tmp", patterns: patterns)

          method = testcase[:matches] ? "assert" : "refute"

          send(method.to_sym, filter.match?(testcase[:input]), "Failed to #{method} match: #{testcase[:pattern]}")
        end
      end

      def test_from_path
        filter = IgnoreFilter.from_path("#{ShopifyCLI::ROOT}/test/fixtures/theme")

        assert_includes(filter.globs, "*config/settings_data.json")
        assert_includes(filter.globs, "*.jpg")
        assert_includes(filter.regexes, /\.(txt|gif|bat)$/)

        # Don't consider empty lines
        refute_includes(filter.globs, "*")
      end

      def test_patterns_to_regexes_and_globs
        tests = [
          { pattern: "config/settings_data.json", glob: "*config/settings_data.json" },
          { pattern: "config/", glob: "*config/*" },
          { pattern: "*.jpg", glob: "*.jpg" },
          { pattern: "/\\.(txt|gif|bat)$/", regex: /\.(txt|gif|bat)$/ },
        ]

        patterns = tests.map { |testcase| testcase[:pattern] }
        filter = IgnoreFilter.new("/tmp", patterns: patterns)

        tests.each do |testcase|
          assert_includes(filter.globs, testcase[:glob]) unless testcase[:glob].nil?
          assert_includes(filter.regexes, testcase[:regex]) unless testcase[:regex].nil?
        end
      end

      def test_add
        filter = IgnoreFilter.new("/tmp")
        test_cases = [
          { pattern: "config/settings_data.json", glob: "*config/settings_data.json" },
          { pattern: "config/", glob: "*config/*" },
          { pattern: "*.jpg", glob: "*.jpg" },
          { pattern: "/\\.(txt|gif|bat)$/", regex: /\.(txt|gif|bat)$/ },
        ]

        test_cases.each do |test_case|
          filter.add_patterns([test_case.fetch(:pattern)])
          assert_includes(filter.globs, test_case.fetch(:glob)) if test_case.key?(:glob)
          assert_includes(filter.regexes, test_case.fetch(:regex)) if test_case.key?(:regex)
        end
      end
    end
  end
end
