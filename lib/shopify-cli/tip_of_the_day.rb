require 'json'

module ShopifyCli
  class TipOfTheDay

    def initialize(path = nil)
      if path
        @path = path
      else
        @path = File.expand_path(ShopifyCli::ROOT + '/lib/tips.json')
      end
    end

    attr_reader :path

    def self.call(*args)
      new(*args).call
    end

    def call
      x = ShopifyCli::Config.get_bool('tipoftheday', 'enabled')
      pp x
      return nil unless x
      tip = next_tip
      return if tip.nil?
      log_tips(tip)
      tip["text"]
    end

    def read_file
      file = File.read(path)
      JSON.parse(file)['tips']
    end

    def next_tip
      tips = read_file
      log = ShopifyCli::Config.get_section("tip_log")

      tips.each do |tip|
        id = tip["id"]
        unless log.keys.include?(id)
          return tip
        end
      end
      return nil
    end

    def log_tips(tip)
      # TODO: change 'tip_log' to tiplog ?
      ShopifyCli::Config.set('tip_log', tip["id"], Time.now.to_i)
    end
  end
end
