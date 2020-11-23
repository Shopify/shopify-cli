# frozen_string_literal: true
require 'test_helper'
require 'shopify-cli/tip_of_the_day'

module ShopifyCli
  class TipOfTheDayTest < MiniTest::Test
    include TestHelpers::FakeFS

    def test_displays_a_random_tip
      root = ShopifyCli::ROOT
      FakeFS::FileSystem.clone(root + '/lib/tips.json')

      tip = {
      "id" => "0",
      "text" => "Creating a new store and need some sample products? Try the `populate` command: https://shopify.github.io/shopify-app-cli/app/rails/commands/#populate",
      "difficulty" => "beginner"
    }
      Array.any_instance.expects(:sample).returns(tip)
      result = TipOfTheDay.call
      puts result.inspect
      assert_includes result, 'Creating a new store'
    end
  end
end
