# frozen_string_literal: true

require "shopify_cli/thread_pool/job"

module ShopifyCLI
  class PartnersAPI
    class AppExtensions
      class Job < ShopifyCLI::ThreadPool::Job
        attr_reader :result

        def initialize(ctx, app, type)
          super()
          @ctx = ctx
          @app = app
          @api_key = @app["apiKey"]
          @type = type
        end

        def perform!
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
