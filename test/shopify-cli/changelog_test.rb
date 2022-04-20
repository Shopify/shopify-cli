# frozen_string_literal: true
require "test_helper"
require "shopify_cli/changelog"

module ShopifyCLI
  class ChangelogTest < MiniTest::Test
    TEST_CHANGELOG = <<~CHANGELOG
      Explanatory note

      ## [Unreleased]

      ### Fixed
      * [#1234](https://github.com/Shopify/shopify-cli/pull/1234): Fixed 1234

      ## Version #{ShopifyCLI::VERSION} - 2022-01-01

      ### Added
      * [#5678](https://github.com/Shopify/shopify-cli/pull/5678): Added 5678
    CHANGELOG

    def test_changelog_outputs_equal_inputs
      assert_equal(Changelog.new.full_contents, File.read(Changelog::CHANGELOG_FILE))
    end

    def test_adding_to_existing_section
      File.expects(:read).with(ShopifyCLI::Changelog::CHANGELOG_FILE).returns(TEST_CHANGELOG)
      pr_id = "9876"
      desc = "Fixed 9876"

      changelog = Changelog.new
      changelog.add_change("Fixed", { pr_id: pr_id, desc: desc })
      assert_includes(changelog.full_contents, <<~UPDATED_SECTION)
        ## [Unreleased]

        ### Fixed
        * [#1234](https://github.com/Shopify/shopify-cli/pull/1234): Fixed 1234
        * [##{pr_id}](https://github.com/Shopify/shopify-cli/pull/#{pr_id}): #{desc}

        ## Version #{ShopifyCLI::VERSION} - 2022-01-01
      UPDATED_SECTION
    end

    def test_adding_to_new_section
      File.expects(:read).with(ShopifyCLI::Changelog::CHANGELOG_FILE).returns(TEST_CHANGELOG)
      pr_id = "5432"
      desc = "Added 5432"

      changelog = Changelog.new
      changelog.add_change("Added", { pr_id: pr_id, desc: desc })
      assert_includes(changelog.full_contents, <<~UPDATED_SECTION)
        ## [Unreleased]

        ### Fixed
        * [#1234](https://github.com/Shopify/shopify-cli/pull/1234): Fixed 1234

        ### Added
        * [##{pr_id}](https://github.com/Shopify/shopify-cli/pull/#{pr_id}): #{desc}

        ## Version #{ShopifyCLI::VERSION} - 2022-01-01
      UPDATED_SECTION
    end

    def test_version_update
      File.expects(:read).with(ShopifyCLI::Changelog::CHANGELOG_FILE).returns(TEST_CHANGELOG)

      changelog = Changelog.new
      changelog.expects(:save!)
      changelog.update_version!("99.99.99")
      assert_equal(changelog.full_contents, <<~UPDATED_SECTION)
        Explanatory note

        ## [Unreleased]

        ## Version 99.99.99 - #{Date.today.iso8601}

        ### Fixed
        * [#1234](https://github.com/Shopify/shopify-cli/pull/1234): Fixed 1234

        ## Version #{ShopifyCLI::VERSION} - 2022-01-01

        ### Added
        * [#5678](https://github.com/Shopify/shopify-cli/pull/5678): Added 5678


      UPDATED_SECTION
    end
  end
end
