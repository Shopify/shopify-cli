module ShopifyCLI
  module Theme
    class ThemeAdminAPI
      API_VERSION = "unstable"

      attr_reader :shop

      def initialize(ctx, shop = nil)
        @ctx = ctx
        @shop = shop || get_shop_or_abort
      end

      def get(path:, **args)
        rest_request(method: "GET", path: path, **args)
      end

      def put(path:, **args)
        rest_request(method: "PUT", path: path, **args)
      end

      def post(path:, **args)
        rest_request(method: "POST", path: path, **args)
      end

      def delete(path:, **args)
        rest_request(method: "DELETE", path: path, **args)
      end

      def get_shop_or_abort # rubocop:disable Naming/AccessorMethodName
        ShopifyCLI::AdminAPI.get_shop_or_abort(@ctx)
      end

      private

      def rest_request(**args)
        ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @shop,
          api_version: API_VERSION,
          **args.compact
        )
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
        if empty_response?(error) || unauthorized_response?(error)
          return permission_error
        end

        raise error
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
