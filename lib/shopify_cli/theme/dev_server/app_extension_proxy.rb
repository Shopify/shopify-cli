# frozen_string_literal: true
require_relative "base_proxy"

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensionProxy < BaseProxy
        def initialize(ctx, extension:, theme:)
          super(ctx)
          @extension = extension

          @shop = theme.shop
          @theme_id = theme.id
        end

        private

        def build_replacement_param(_env)
          []
        end
      end
    end
  end
end
