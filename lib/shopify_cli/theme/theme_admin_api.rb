module ShopifyCLI
  module Theme
    class ThemeAdminAPI
      API_VERSION = "unstable"

      def initialize(ctx, shop = nil)
        @ctx = ctx
        @shop = shop || get_shop_or_abort
      end

      def get(path:, **args)
        rest_request(
          path: path,
          **args
        )
      end

      def put(path:, **args)
        rest_request(
          method: "PUT",
          path: path,
          **args
        )
      end

      def post(path:, **args)
        rest_request(
          method: "POST",
          path: path,
          **args
        )
      end

      def delete(path:, **args)
        rest_request(
          method: "DELETE",
          path: path,
          **args
        )
      end

      def get_shop_or_abort
        ShopifyCLI::AdminAPI.get_shop_or_abort(@ctx)
      end

      private

      def rest_request(**args)
        puts "here in rest_request"

        ShopifyCLI::AdminAPI.rest_request(
          @ctx,
          shop: @shop,
          api_version: API_VERSION,
          **args.compact
        )
      rescue ShopifyCLI::API::APIRequestForbiddenError,
             ShopifyCLI::API::APIRequestUnauthorizedError
        handle_permissions_error
      end

      def handle_permissions_error
        # theme = ShopifyCLI::Theme::Theme.new(ctx)
        # @ctx.abort(ctx.message("theme.ensure_user", theme.shop))
        @ctx.abort(ctx.message("theme.ensure_user", get_shop_or_abort))
      end

    end
  end
end
