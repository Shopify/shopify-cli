# frozen_string_literal: true
require "test_helper"
require "shopify_cli/changelog"

module ShopifyCLI
  class ChangelogTest < MiniTest::Test
    def test_changelog_outputs_equal_inputs
      assert_equal(Changelog.new.full_contents, File.read(Changelog::CHANGELOG_FILE))
    end
  end
end
