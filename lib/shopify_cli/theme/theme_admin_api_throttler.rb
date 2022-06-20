# frozen_string_literal: true

require "forwardable"

require_relative "theme_admin_api_throttler/bulk"
require_relative "theme_admin_api_throttler/put_request"

module ShopifyCLI
  module Theme
    class ThemeAdminAPIThrottler
      extend Forwardable

      attr_reader :bulk, :admin_api

      def_delegators :@admin_api, :get, :post, :delete

      def initialize(ctx, admin_api, active = true)
        @ctx = ctx
        @admin_api = admin_api
        @active = active
        @bulk = Bulk.new(ctx, admin_api)
      end

      def put(path:, **args, &block)
        request = PutRequest.new(path, args[:body], &block)
        if active?
          bulk_request(request)
        else
          rest_request(request)
        end
      end

      def activate_throttler!
        @active = true
      end

      def deactivate_throttler!
        @active = false
      end

      def active?
        @active
      end

      def shutdown
        bulk.shutdown
      end

      private

      def rest_request(request)
        request.block.call(admin_api.rest_request(**request.to_h))
      rescue StandardError => error
        request.block.call(500, {}, error)
      end

      def bulk_request(request)
        bulk.enqueue(request)
      end
    end
  end
end
