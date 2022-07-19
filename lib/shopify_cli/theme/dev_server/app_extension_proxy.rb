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
          return []

          AppExtensionTemplateParamBuilder.new
            .with_core_endpoints(@core_endpoints)
            .with_theme(@theme)
            .with_rack_env(env)
            .build
        end
      end
    end
  end
end
