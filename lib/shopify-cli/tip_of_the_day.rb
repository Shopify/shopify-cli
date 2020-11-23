require 'json'

module ShopifyCli
  class TipOfTheDay
    def self.call
      tip = random_tip
      log_tips(tip)
      puts tip["text"]
    end

    def self.read_file
      path = File.expand_path(ShopifyCli::ROOT + '/lib/tips.json')
      file = File.read(path)
      JSON.parse(file)['tips']
    end

    def self.random_tip
      tips = read_file
      tips.sample
    end

    def self.log_tips(tip)
      ShopifyCli::Config.set('tip_log', tip["id"], (Time.now.utc.to_f * 1000).to_i)
    end
  end
end
