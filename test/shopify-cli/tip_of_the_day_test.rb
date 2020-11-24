# frozen_string_literal: true
require 'test_helper'
require 'shopify-cli/tip_of_the_day'
require 'timecop'

module ShopifyCli
  class TipOfTheDayTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      root = ShopifyCli::ROOT
      FakeFS::FileSystem.clone(root + '/test/fixtures/tips.json')
      FakeFS::FileSystem.clone(root + '/lib/tips.json')
      @tips_path = File.expand_path(ShopifyCli::ROOT + '/test/fixtures/tips.json')

      @remote_request = stub_request(:get, "https://gist.githubusercontent.com/andyw8/c772d254b381789f9526c7b823755274/raw/4b227372049d6a6e5bb7fa005f261c4570c53229/tips.json").
  with(
    headers: {
          'Accept'=>'*/*',
          'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Host'=>'gist.githubusercontent.com',
          'User-Agent'=>'Ruby'
    }).
  to_return(status: 200, body: File.read(@tips_path), headers: {})
    end

    def teardown
      ShopifyCli::Config.clear
      super
    end

    def test_displays_first_tip
      result = TipOfTheDay.call(@tips_path)
      assert_includes result, 'Creating a new store'
    end

    def test_displays_sequential_tip
      TipOfTheDay.call(@tips_path)
      Timecop.travel(36 * 60 * 60) do
        result = TipOfTheDay.call(@tips_path)
        assert_includes result, 'Did you know this CLI is open source'
      end
    end

    def test_displays_nothing_when_all_tips_have_been_seen
      3.times do
        TipOfTheDay.call(@tips_path)
      end

      assert_nil TipOfTheDay.call(@tips_path)
    end

    def test_no_tips_shown_if_disabled_in_config
      ShopifyCli::Config.set('tipoftheday', 'enabled', false)

      assert_nil TipOfTheDay.call(@tips_path)
    end

    def test_tips_shown_if_reenabled_in_config
      ShopifyCli::Config.set('tipoftheday', 'enabled', false)

      assert_nil TipOfTheDay.call(@tips_path)

      ShopifyCli::Config.set('tipoftheday', 'enabled', true)
      result = TipOfTheDay.call(@tips_path)

      assert_includes result, 'Creating a new store'
    end

    def test_only_shows_one_tip_per_day
      TipOfTheDay.call(@tips_path)
      assert_nil TipOfTheDay.call(@tips_path)
    end

    def test_fetches_tips_from_remote
      TipOfTheDay.call

      assert_requested(@remote_request)
    end 

    def test_saves_local_copy_of_fetched_tip_data 
      TipOfTheDay.call 
      assert File.exists?(File.expand_path('~/.config/shopify/tips.json'))
    end 

    def test_fetching_tips_updates_config_timestamp
      Timecop.freeze do |time| 
        TipOfTheDay.call 
        last_read_time = ShopifyCli::Config.get('tipoftheday', 'lastfetched').to_i
        assert_equal last_read_time, time.to_i
      end 
    end 
  end
end
