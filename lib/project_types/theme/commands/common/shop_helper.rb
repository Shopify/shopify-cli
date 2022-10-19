# frozen_string_literal: true

module Theme
  class Command
    module Common
      module ShopHelper
        def shop
          ShopifyCLI::Theme::ThemeAdminAPI.new(@ctx).get_shop_or_abort
        end
      end
    end
  end
end
