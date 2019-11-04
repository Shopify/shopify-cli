module ShopifyCli
  module Helpers
    module Async
      class << self
        def in_thread(&block)
          Thread.new(&block)
        end
      end
    end
  end
end
