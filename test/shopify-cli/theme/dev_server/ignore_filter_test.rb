# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class IgnoreFilterTest < Minitest::Test
  def test_new_filter
    filter = ShopifyCli::Theme::DevServer::IgnoreFilter.new("/tmp")

    assert_equal("/tmp", filter.root)
    assert_equal(ShopifyCli::Theme::DevServer::IgnoreFilter::DEFAULT_REGEXES, filter.regexes)
    assert_equal(ShopifyCli::Theme::DevServer::IgnoreFilter::DEFAULT_GLOBS, filter.globs)

    assert_raises(ShopifyCli::Theme::DevServer::IgnoreFilter::IgnoreFileDoesNotExist) do
      ShopifyCli::Theme::DevServer::IgnoreFilter.new("/tmp", files: ["does not exist"])
    end
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
      filter = ShopifyCli::Theme::DevServer::IgnoreFilter.new("/tmp", patterns: patterns)

      method = testcase[:matches] ? "assert" : "refute"

      send(method.to_sym, filter.match?(testcase[:input]), "Failed to #{method} match: #{testcase[:pattern]}")
    end
  end

  def test_ignores_file
    filter = ShopifyCli::Theme::DevServer::IgnoreFilter.new(
      "#{ShopifyCli::ROOT}/test/fixtures/theme", files: ["ignores_file"]
    )

    assert_includes(filter.globs, "*config/settings_data.json")
    assert_includes(filter.globs, "*.png")
    assert_includes(filter.regexes, /\.(txt|gif|bat)$/)

    # Don't consider empty lines
    refute_includes(filter.globs, "*")
  end

  def test_patterns_to_regexes_and_globs
    tests = [
      { pattern: "config/settings_data.json", glob: "*config/settings_data.json" },
      { pattern: "config/", glob: "*config/*" },
      { pattern: "*.png", glob: "*.png" },
      { pattern: "/\\.(txt|gif|bat)$/", regex: /\.(txt|gif|bat)$/ },
    ]

    patterns = tests.map { |testcase| testcase[:pattern] }
    filter = ShopifyCli::Theme::DevServer::IgnoreFilter.new("/tmp", patterns: patterns)

    tests.each do |testcase|
      assert_includes(filter.globs, testcase[:glob]) unless testcase[:glob].nil?
      assert_includes(filter.regexes, testcase[:regex]) unless testcase[:regex].nil?
    end
  end
end
