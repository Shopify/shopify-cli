require 'shopify_cli'

module ShopifyCli
  class Task
    def self.call(*args)
      task = new
      task.call(*args)
    end
  end
end
