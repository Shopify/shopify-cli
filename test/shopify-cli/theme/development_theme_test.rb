# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/development_theme"

module ShopifyCLI
  module Theme
    class DevelopmentThemeTest < Minitest::Test
      def setup
        super
        root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: root)
        @theme = DevelopmentTheme.new(@ctx, root: root)
        ShopifyCLI::DB.stubs(:del).with(:acting_as_shopify_organization)
      end

      def test_creates_development_theme_if_missing_from_storage
        shop = "dev-theme-server-store.myshopify.com"
        theme_name = "Development (5676d8-theme-dev)"

        ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(shop)
        ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns(nil)
        ShopifyCLI::DB.expects(:set).with(development_theme_id: "12345678")
        @theme.stubs(:name).returns(theme_name)

        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: shop,
          api_version: "unstable",
          method: "POST",
          path: "themes.json",
          body: JSON.generate({
            theme: {
              name: theme_name,
              role: "development",
            },
          }),

        ).returns([
          201,
          "theme" => {
            "id" => "12345678",
          },
        ])

        @theme.ensure_exists!
      end

      def test_creates_development_theme_when_an_unauthorized_error_happens
        shop = "dev-theme-server-store.myshopify.com"
        theme_id = "12345678"
        error_message = "error message"
        unauthorized_error_response = stub(body: '{"errors":"Unauthorized Access"}')
        unauthorized_error = ShopifyCLI::API::APIRequestForbiddenError.new("403", response: unauthorized_error_response)

        ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(shop)
        ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns(theme_id)

        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: shop,
          api_version: "unstable",
          method: "GET",
          path: "themes/#{theme_id}.json",
        ).raises(unauthorized_error)

        @ctx.expects(:message).with("theme.unauthorized_error", shop).returns(error_message)

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          @theme.ensure_exists!
        end
        assert_message_output(io: io, expected_content: [error_message])
      end

      def test_creates_development_theme_if_missing_from_api
        shop = "dev-theme-server-store.myshopify.com"
        theme_name = "Development (5676d8-theme-dev)"
        theme_id = "12345678"

        ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(shop)
        ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns(theme_id)
        ShopifyCLI::DB.expects(:set).with(development_theme_id: "12345678")
        @theme.stubs(:name).returns(theme_name)

        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: shop,
          api_version: "unstable",
          method: "GET",
          path: "themes/#{theme_id}.json",

        ).raises(ShopifyCLI::API::APIRequestNotFoundError)

        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: shop,
          api_version: "unstable",
          method: "POST",
          path: "themes.json",
          body: JSON.generate({
            theme: {
              name: theme_name,
              role: "development",
            },
          }),

        ).returns([
          201,
          "theme" => {
            "id" => "12345678",
          },
        ])

        @theme.ensure_exists!
      end

      def test_name_is_generated_unless_exists_in_db
        hostname = "theme-dev.lan"
        hash = "5676d"
        theme_name = "Development (#{hash}-#{hostname.split(".").shift})"

        ShopifyCLI::DB.stubs(:get).with(:development_theme_name).returns(nil)
        SecureRandom.expects(:hex).returns(hash)
        Socket.expects(:gethostname).returns(hostname)
        ShopifyCLI::DB.expects(:set).with(development_theme_name: theme_name)

        assert_equal(theme_name, @theme.name)
      end

      def test_name_is_generated_if_the_existing_name_length_is_above_the_api_limit
        # Given
        hostname = "theme-dev-lan-very-long-name-that-will-be-truncated"
        hash = "5676d"
        theme_name = "Development ()"
        hostname_character_limit = ShopifyCLI::Theme::API_NAME_LIMIT - theme_name.length - hash.length - 1
        identifier = "#{hash}-#{hostname[0, hostname_character_limit]}"
        theme_name_without_truncation = "Development (#{hash}-#{hostname})"
        theme_name = "Development (#{identifier})"

        ShopifyCLI::DB.stubs(:get).with(:development_theme_name).returns(theme_name_without_truncation)
        SecureRandom.expects(:hex).returns(hash)
        Socket.expects(:gethostname).returns(hostname)
        ShopifyCLI::DB.expects(:set).with(development_theme_name: theme_name)

        # When/Then
        assert_equal(theme_name, @theme.name)
      end

      def test_name_is_truncated_if_its_above_the_api_limit
        # Given
        hostname = "theme-dev-lan-very-long-name-that-will-be-truncated"
        hash = "5676d"
        theme_name = "Development ()"
        hostname_character_limit = ShopifyCLI::Theme::API_NAME_LIMIT - theme_name.length - hash.length - 1
        identifier = "#{hash}-#{hostname[0, hostname_character_limit]}"
        theme_name = "Development (#{identifier})"

        ShopifyCLI::DB.stubs(:get).with(:development_theme_name).returns(nil)
        SecureRandom.expects(:hex).returns(hash)
        Socket.expects(:gethostname).returns(hostname)
        ShopifyCLI::DB.expects(:set).with(development_theme_name: theme_name)

        # When/Then
        assert_equal(theme_name, @theme.name)
      end

      def test_delete
        shop = "dev-theme-server-store.myshopify.com"
        theme_id = "12345678"

        ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(shop)
        ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns(theme_id)
        ShopifyCLI::DB.stubs(:exists?).with(:development_theme_id).returns(true)
        ShopifyCLI::DB.stubs(:del).with(:development_theme_id)
        ShopifyCLI::DB.stubs(:exists?).with(:development_theme_name).returns(true)
        ShopifyCLI::DB.stubs(:del).with(:development_theme_name)

        @theme.expects(:exists?).returns(true)

        ShopifyCLI::AdminAPI.expects(:rest_request).with(
          @ctx,
          shop: shop,
          path: "themes/#{theme_id}.json",
          method: "DELETE",
          api_version: "unstable",
        )

        @theme.delete
      end
    end
  end
end
