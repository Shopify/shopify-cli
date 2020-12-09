module ShopifyCli
  class TipOfTheDay
    WEEK_IN_SECONDS = 7 * 24 * 60 * 60
    DAY_IN_SECONDS = 24 * 60 * 60
    TIPS_URL = "https://raw.githubusercontent.com/Shopify/shopify-app-cli/tip-of-the-day/docs/tips.json"

    def initialize(path = nil)
      @path = if path
        path
      else
        File.expand_path(ShopifyCli::ROOT + '/lib/tips.json')
      end
    end

    attr_reader :path

    def self.call(*args)
      new(*args).call
    end

    def call
      if ShopifyCli::Config.get_section('tipoftheday') == {}
        ShopifyCli::Config.set('tipoftheday', 'enabled', true)
      end
      return nil unless ShopifyCli::Config.get_bool('tipoftheday', 'enabled')
      tip = next_tip
      return if tip.nil?
      log_tips(tip)
      tip["text"]
    end

    def next_tip
      tips = fetch_tip
      return if tips.nil?
      log = ShopifyCli::Config.get_section("tiplog")

      return unless has_it_been_a_day_since_last_tip?(log)
      tips.each do |tip|
        id = tip["id"]
        unless log.keys.include?(id)
          return tip
        end
      end
      nil
    end

    def log_tips(tip)
      ShopifyCli::Config.set('tiplog', tip["id"], Time.now.to_i)
    end

    def has_it_been_a_day_since_last_tip?(log)
      most_recent_tip = log.values.last
      return true unless most_recent_tip
      now = Time.now.to_i
      now - most_recent_tip.to_i > DAY_IN_SECONDS
    end

    def fetch_tip
      require 'shopify-cli/http_request'
      require 'json'

      last_read_time = ShopifyCli::Config.get('tipoftheday', 'lastfetched')
      if !last_read_time || (Time.now.to_i - last_read_time.to_i > WEEK_IN_SECONDS)

        response = HttpRequest.with_network_errors_silenced do
          HttpRequest.get(URI(TIPS_URL), read_timeout: 5)
        end

        return unless response

        tips_content = response.body
        File.write(ShopifyCli.tips_file, tips_content)
        ShopifyCli::Config.set('tipoftheday', 'lastfetched', Time.now.to_i)
      else
        tips_content = File.read(ShopifyCli.tips_file)
      end
      begin
        JSON.parse(tips_content).fetch("tips")
      rescue JSON::ParserError, KeyError
        # fail silently
      end
    end
  end
end
