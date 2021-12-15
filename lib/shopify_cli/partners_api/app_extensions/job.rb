# frozen_string_literal: true

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class Job
        attr_reader :result

        def initialize(ctx, app, type)
          @ctx = ctx
          @app = app
          @api_key = @app["apiKey"]
          @type = type
        end

        def fetch_extensions!
          resp = PartnersAPI.query(@ctx, "get_extension_registrations", **params)
          @result = resp&.dig("data", "app") || {}
        end

        def patch_app_with_extensions!
          @app.merge!(result)
        end

        private

        def params
          { api_key: @api_key, type: @type }
        end
      end
    end
  end
end
