# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class RequestParser
        def initialize(requests)
          @requests = requests
        end

        def parse
          {
            path: path,
            method: method,
            body: JSON.generate({ assets: assets }),
          }
        end

        private

        def method
          @requests.sample.method
        end

        def path
          @requests.sample.bulk_path
        end

        def assets
          @requests.map do |request|
            body = JSON.parse(request.body)
            body = body.is_a?(Hash) ? body : JSON.parse(body)
            body["asset"]
          end
        end
      end
    end
  end
end
