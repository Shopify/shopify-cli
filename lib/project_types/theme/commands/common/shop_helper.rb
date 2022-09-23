# frozen_string_literal: true

module Theme
  class Command
    module Common
      module ShopHelper
        def shop
          ShopifyCLI::AdminAPI.get_shop_or_abort(@ctx)
        end
      end
    end
  end
end
