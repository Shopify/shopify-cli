require 'json'

module ShopifyCli
  class TipOfTheDay
    def self.call
      puts random_tip
    end

    def self.read_file
      path = File.expand_path(ShopifyCli::ROOT + '/lib/tips.json')
      file = File.read(path)
      JSON.parse(file)['tips']
    end

    def self.random_tip
      tips = read_file
      tips.sample["text"]
    end
  end
end
