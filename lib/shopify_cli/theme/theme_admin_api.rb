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
        # The Admin API returns 403 Forbidden responses on different
        # scenarios:
        #
        # * when a user doesn't have permissions for a request:
        #   <APIRequestForbiddenError: 403 {}>
        #
        # * when an asset operation cannot be performed:
        #   <APIRequestForbiddenError: 403 {"message":"templates/gift_card.liquid could not be deleted"}>
        if empty_response_error?(error)
          return handle_permissions_error
        end

        raise error
      end

      def handle_permissions_error
        ensure_user_error = @ctx.message("theme.ensure_user_error", shop)
        ensure_user_try_this = @ctx.message("theme.ensure_user_try_this")

        @ctx.abort(ensure_user_error, ensure_user_try_this)
      end

      def empty_response_error?(error)
        error_message = error&.response&.body.to_s
        error_message.empty?
      end
    end
  end
end
