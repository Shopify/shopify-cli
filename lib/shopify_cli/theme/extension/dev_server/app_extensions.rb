# frozen_string_literal: true

module ShopifyCLI
  module Theme
    module Extension
      class DevServer < ShopifyCLI::Theme::DevServer
        class AppExtensions
          def call(_env)
            headers = {}

            headers["Content-Type"] = "text/plain"
            [200, headers, ["Hello, World!"]]
          end

          def close
            @streams.close
          end
        end
      end
    end
  end
end
