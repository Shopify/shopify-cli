# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class AppExtensions
        # def initialize
        #   @app = app
        # end

        def call(env)
          # TODO use HeaderHash
          headers = {}

          headers['Content-Type'] = 'text/plain'
          [200, headers, ['Hello, World!']]
        end
      end
    end
  end
end
