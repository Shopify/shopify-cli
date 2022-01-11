# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module DevServer
      class DevHeaders
        BLOCKED_HEADERS = %w(content-security-policy)

        def initialize(app)
          @app = app
        end

        def call(env)
          status, headers, body = @app.call(env)
          dev_headers = filter(headers)

          [status, dev_headers, body]
        end

        private

        def filter(headers)
          headers.reject { |key, _v| BLOCKED_HEADERS.include?(key) }
        end
      end
    end
  end
end
