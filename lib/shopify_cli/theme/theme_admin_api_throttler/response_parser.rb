# frozen_string_literal: true

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      class ResponseParser
        def initialize(response_body)
          @response_body = response_body
        end

        def parse
          result = []
          @response_body["results"]&.each do |resp|
            result << [resp["code"], resp["body"]]
          end
          result
        end
      end
    end
  end
end
