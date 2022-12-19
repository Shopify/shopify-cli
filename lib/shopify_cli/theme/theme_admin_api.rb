# frozen_string_literal: true

require_relative "theme_access_api"

module ShopifyCLI
  module Theme
    class ThemeAdminAPI
      API_VERSION = "unstable"

      attr_reader :shop

      def initialize(ctx, shop = nil)
        @ctx = ctx
        @shop = shop || get_shop_or_abort
      end

      def get(path:, **args, &block)
        rest_request(method: "GET", path: path, **args, &block)
      end

      def put(path:, **args, &block)
        rest_request(method: "PUT", path: path, **args, &block)
      end

      def post(path:, **args, &block)
        rest_request(method: "POST", path: path, **args, &block)
      end

      def delete(path:, **args, &block)
        rest_request(method: "DELETE", path: path, **args, &block)
      end

      def get_shop_or_abort # rubocop:disable Naming/AccessorMethodName
        api_client.get_shop_or_abort(@ctx)
      end

      def rest_request(**args)
        status, body, response = api_client.rest_request(
          @ctx,
          shop: @shop,
          api_version: API_VERSION,
          **args.compact
        )
        return yield(status, body, response) if block_given?

        [status, body, response]
      rescue ShopifyCLI::API::APIRequestForbiddenError,
             ShopifyCLI::API::APIRequestUnauthorizedError => error

        ##
        # The Admin API returns 403 Forbidden responses on different
        # scenarios:
        #
        # * when a user doesn't have permissions for a request:
        #   - <APIRequestForbiddenError: 403 {}>
        #   - <APIRequestForbiddenError: 403 {"errors":"Unauthorized Access"}>
        #
        # * when an asset operation cannot be performed:
        #   - <APIRequestForbiddenError: 403 {"message":"templates/gift_card.liquid could not be deleted"}>
        #
        if empty_response?(error)
          return permission_error
        elsif unauthorized_response?(error)
          @ctx.debug("[#{self.class}] (#{error.class}) cause: #{response_body(error)}")
          raise ShopifyCLI::Abort, @ctx.message("theme.unauthorized_error", @shop)
        end

        raise error
      end

      private

      def api_client
        @api_client ||= Environment.theme_access_password? ? ThemeAccessAPI : ShopifyCLI::AdminAPI
      end

      def permission_error
        ensure_user_error = @ctx.message("theme.ensure_user_error", shop)
        ensure_user_try_this = @ctx.message("theme.ensure_user_try_this")

        @ctx.abort(ensure_user_error, ensure_user_try_this)
      end

      def empty_response?(error)
        response_body(error).empty?
      end

      def unauthorized_response?(error)
        parsed_body = JSON.parse(response_body(error))
        errors = parsed_body["errors"].to_s
        errors.match?(/Unauthorized Access/)
      rescue JSON::ParserError
        false
      end

      def response_body(error)
        error&.response&.body.to_s
      end
    end
  end
end
