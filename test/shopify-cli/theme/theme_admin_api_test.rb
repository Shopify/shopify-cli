# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/theme_admin_api"

module ShopifyCLI
  module Theme
    class ThemeAdminApiTest < Minitest::Test
      def setup
        super
        @root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: @root)
        @shop = "dev-theme-server-store.myshopify.com"
        @api_version = "unstable"
        @api_client = ThemeAdminAPI.new(@ctx, @shop)
      end

      def test_sets_shop_if_not_passed_in
        ShopifyCLI::AdminAPI.expects(:get_shop_or_abort)
          .with(@ctx)
          .returns(@shop)

        theme_admin_api = ThemeAdminAPI.new(@ctx)

        assert_equal(theme_admin_api.shop, @shop)
      end

      def test_get
        path = "themes.json"
        request_params = {
          method: "GET",
          path: path,
        }

        expect_correct_request_arguments(request_params)

        @api_client.get(
          path: path
        )
      end

      def test_put
        path = "themes/123.json"
        body = JSON.generate(theme: {
          role: "main",
        })

        request_params = {
          method: "PUT",
          path: path,
          body: body,
        }

        expect_correct_request_arguments(request_params)

        @api_client.put(
          path: path,
          body: body
        )
      end

      def test_post
        path = "themes.json"
        body = JSON.generate(theme: {
          role: "main",
        })

        request_params = {
          method: "POST",
          path: path,
          body: body,
        }

        expect_correct_request_arguments(request_params)

        @api_client.post(
          path: path,
          body: body
        )
      end

      def test_delete
        path = "themes/123.json"
        request_params = {
          method: "DELETE",
          path: path,
        }

        expect_correct_request_arguments(request_params)

        @api_client.delete(
          path: path
        )
      end

      def test_can_get_shop_or_abort
        ShopifyCLI::AdminAPI.expects(:get_shop_or_abort)
          .with(@ctx)
          .returns(@shop)

        @api_client.get_shop_or_abort
      end

      def test_correctly_all_maps_params_to_admin_api
        request_params = {
          method: "POST",
          path: "themes.json",
          query: "query",
          body: JSON.generate({ theme: {} }),
          token: "token123",
        }

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, shop: @shop, api_version: @api_version, **request_params)

        @api_client.send(:rest_request, **request_params)
      end

      def test_does_not_pass_nil_arguments
        path = "themes.json"
        body = nil

        request_params = {
          method: "POST",
          path: path,
        }

        expect_correct_request_arguments(request_params)

        @api_client.post(
          path: path,
          body: body
        )
      end

      def test_graceullly_handles_api_permissions_errors
        path = "themes.json"

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, shop: @shop, api_version: @api_version, method: "POST", path: path)
          .raises(ShopifyCLI::API::APIRequestForbiddenError)

        @ctx.expects(:message).with("theme.ensure_user_error", @shop).returns("ensure_user_error")
        @ctx.expects(:message).with("theme.ensure_user_try_this").returns("ensure_user_try_this")
        @ctx.expects(:abort).with("ensure_user_error", "ensure_user_try_this")

        @api_client.post(
          path: path
        )
      end

      def test_forbiden_errors_related_to_unauthorized_access
        path = "themes.json"
        error_response = stub(body: '{"errors":"Unauthorized Access"}')
        expected_error = ShopifyCLI::API::APIRequestForbiddenError.new("403", response: error_response)

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, shop: @shop, api_version: @api_version, method: "POST", path: path)
          .raises(expected_error)

        @ctx.expects(:message).with("theme.ensure_user_error", @shop).returns("ensure_user_error")
        @ctx.expects(:message).with("theme.ensure_user_try_this").returns("ensure_user_try_this")
        @ctx.expects(:abort).with("ensure_user_error", "ensure_user_try_this")

        @api_client.post(
          path: path
        )
      end

      def test_forbiden_errors_not_related_to_unauthorized_access
        path = "themes.json"
        error_response = stub(body: '{"message":"templates/gift_card.liquid could not be deleted"}')
        expected_error = ShopifyCLI::API::APIRequestForbiddenError.new("403", response: error_response)

        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, shop: @shop, api_version: @api_version, method: "POST", path: path)
          .raises(expected_error)

        actual_error = assert_raises(ShopifyCLI::API::APIRequestForbiddenError) do
          @api_client.post(path: path)
        end

        assert_equal(expected_error, actual_error)
      end

      def test_unauthorized_response_with_nil_error
        error = nil
        refute(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_nil_response
        error = stub(response: nil)
        refute(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_nil_body
        response = stub(body: nil)
        error = stub(response: response)
        refute(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_invalid_json
        body = '{"errors":"Unauthorized Access")))'
        response = stub(body: body)
        error = stub(response: response)
        refute(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_no_error
        body = '{"message":"templates/gift_card.liquid could not be deleted"}'
        response = stub(body: body)
        error = stub(response: response)
        refute(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_unauthorized_error
        body = '{"errors":"Unauthorized Access"}'
        response = stub(body: body)
        error = stub(response: response)
        assert(@api_client.send(:unauthorized_response?, error))
      end

      def test_unauthorized_response_with_other_error
        body = '{"errors":"500 Internal Server Error"}'
        response = stub(body: body)
        error = stub(response: response)
        refute(@api_client.send(:unauthorized_response?, error))
      end

      private

      def expect_correct_request_arguments(request_params)
        ShopifyCLI::AdminAPI.expects(:rest_request)
          .with(@ctx, shop: @shop, api_version: @api_version, **request_params)
      end
    end
  end
end
