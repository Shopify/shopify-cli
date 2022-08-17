# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class HotReload
        class Hook
          def call
            raise "#{self.class.name}#call must be defined!"
          end
        end
      end
    end
  end
end
