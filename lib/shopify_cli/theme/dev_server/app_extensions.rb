# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensions
        def initialize(app, theme:)
          @app = app
        end

        def call(env)
          # TODFO
        end
      end
    end
  end
end
