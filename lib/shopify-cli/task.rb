require 'shopify_cli'

module ShopifyCli
  class Task
    def self.call(*args, **kwargs)
      task = new
      task.call(*args, **kwargs)
    end
  end
end
