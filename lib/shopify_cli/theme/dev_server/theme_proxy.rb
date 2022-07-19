# frozen_string_literal: true
require_relative "base_proxy"

module ShopifyCLI
  module Theme
    module DevServer
      # Created for separation of unit tests
      class ThemeProxy < BaseProxy
        def initialize(ctx, theme:, syncer:)
          super(ctx)
          @theme = theme
          @syncer = syncer

          @shop = @theme.shop
          @theme_id = @theme.id
        end

        private

        def build_replacement_param(env)
          ThemeTemplateParamBuilder.new
            .with_core_endpoints(@core_endpoints)
            .with_syncer(@syncer)
            .with_theme(@theme)
            .with_rack_env(env)
            .build
        end
      end
    end
  end
end
