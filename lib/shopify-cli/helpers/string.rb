module ShopifyCli
  module Helpers
    module String
      class << self
        def cap_first(str)
          str = str.to_s
          str[0] = str[0].upcase
          str
        end
      end
    end
  end
end
