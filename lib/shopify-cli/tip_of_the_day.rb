require 'json'

module ShopifyCli
  class TipOfTheDay
    def self.call
      tip = next_tip
      return if tip.nil?
      log_tips(tip)
      tip["text"]
    end

    def self.read_file
      path = File.expand_path(ShopifyCli::ROOT + '/lib/tips.json')
      file = File.read(path)
      JSON.parse(file)['tips']
    end

    def self.next_tip
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

    def self.log_tips(tip)
      ShopifyCli::Config.set('tip_log', tip["id"], Time.now.to_i)
    end
  end
end
