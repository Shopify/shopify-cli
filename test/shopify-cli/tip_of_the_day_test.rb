# frozen_string_literal: true
require 'test_helper'
require 'shopify-cli/tip_of_the_day'

module ShopifyCli
  class TipOfTheDayTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      root = ShopifyCli::ROOT
      FakeFS::FileSystem.clone(root + '/lib/tips.json')
    end

    def test_displays_first_tip
      result = TipOfTheDay.call
      puts result.inspect
      assert_includes result, 'Creating a new store'
    end

    def test_displays_sequential_tip
      TipOfTheDay.call
      result = TipOfTheDay.call
      puts result.inspect
      assert_includes result, 'Did you know this CLI is open source'
    end
  end
end
