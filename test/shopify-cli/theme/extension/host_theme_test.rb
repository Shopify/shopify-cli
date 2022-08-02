# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/extension/host_theme"

module ShopifyCLI
  module Theme
    module Extension
      class HostThemeTest < Minitest::Test
        def setup
          super
          @shop = "dev-theme-server-store.myshopify.com"
          ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(@shop)
          ShopifyCLI::DB.stubs(:del).with(:acting_as_shopify_organization)

          root = ShopifyCLI::ROOT + "/test/fixtures/theme"
          @ctx = TestHelpers::FakeContext.new(root: root)
          @syncer = stub("Syncer", lock_io!: nil, unlock_io!: nil, has_any_error?: false)
          @host_theme = HostTheme.new(@ctx, root: root)
        end

        def teardown
          super
          @host_theme.delete
        end

        def test_creates_host_theme_if_missing_from_storage
          theme_name = "App Ext. Host (143d5e-theme-dev)"
          ShopifyCLI::DB.stubs(:get).with(:host_theme_id).returns(nil)
          ShopifyCLI::DB.stubs(:get).with(:host_theme_name).returns(theme_name)
          ShopifyCLI::DB.expects(:set).with(host_theme_id: "12345678")

          ShopifyCLI::Theme::Syncer.expects(:new)
                                   .with(@ctx, theme: @host_theme)
                                   .returns(@syncer)

          @syncer.expects(:start_threads)
          @syncer.expects(:shutdown)

          @syncer.expects(:upload_theme!).with(delete: false)

          ShopifyCLI::AdminAPI.expects(:rest_request).with(
            @ctx,
            shop: @shop,
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

          capture_io do
            @host_theme.ensure_exists!
          end
        end

        def test_delete
          theme_id = "12345678"

          ShopifyCLI::AdminAPI.stubs(:get_shop_or_abort).returns(@shop)
          ShopifyCLI::DB.stubs(:get).with(:host_theme_id).returns(theme_id)
          ShopifyCLI::DB.stubs(:exists?).with(:host_theme_id).returns(true)
          ShopifyCLI::DB.stubs(:del).with(:host_theme_id)
          ShopifyCLI::DB.stubs(:exists?).with(:host_theme_name).returns(true)
          ShopifyCLI::DB.stubs(:del).with(:host_theme_name)

          @host_theme.expects(:exists?).returns(true)

          ShopifyCLI::AdminAPI.expects(:rest_request).with(
            @ctx,
            shop: @shop,
            path: "themes/#{theme_id}.json",
            method: "DELETE",
            api_version: "unstable",
            )

          @host_theme.delete
        end

        def test_name_is_valid_when_the_host_contains_an_ascii_character
          ascii_string_char = 0x8f.chr
          hostname = "theme-dev-#{ascii_string_char}.lan"
          hash = "143d5e"
          theme_name = "App Ext. Host (143d5e-theme-dev--)"

          ShopifyCLI::DB.stubs(:get).with(:host_theme_name).returns(nil)
          SecureRandom.expects(:hex).returns(hash)
          Socket.expects(:gethostname).returns(hostname)
          ShopifyCLI::DB.expects(:set).with(host_theme_name: theme_name)

          assert_equal(theme_name, @host_theme.name)
        end

        def test_name_is_truncated_if_its_above_the_api_limit
          # Given
          hostname = "theme-dev-lan-very-long-name-that-will-be-truncated"
          hash = "5676d"
          host_theme_name = "App Ext. Host ()"
          hostname_character_limit = ShopifyCLI::Theme::API_NAME_LIMIT - host_theme_name.length - hash.length - 1
          identifier = "#{hash}-#{hostname[0, hostname_character_limit]}"
          host_theme_name = "App Ext. Host (#{identifier})"

          ShopifyCLI::DB.stubs(:get).with(:host_theme_name).returns(nil)
          SecureRandom.expects(:hex).returns(hash)
          Socket.expects(:gethostname).returns(hostname)
          ShopifyCLI::DB.expects(:set).with(host_theme_name: host_theme_name)

          # When/Then
          assert_equal(host_theme_name, @host_theme.name)
        end

        def test_name_is_generated_if_the_existing_name_length_is_above_the_api_limit
          # Given
          hostname = "theme-dev-lan-very-long-name-that-will-be-truncated"
          hash = "5676d"
          host_theme_name = "App Ext. Host ()"
          hostname_character_limit = ShopifyCLI::Theme::API_NAME_LIMIT - host_theme_name.length - hash.length - 1
          identifier = "#{hash}-#{hostname[0, hostname_character_limit]}"
          theme_name_without_truncation = "App Ext. Host (#{hash}-#{hostname})"
          host_theme_name = "App Ext. Host (#{identifier})"

          ShopifyCLI::DB.stubs(:get).with(:host_theme_name).returns(theme_name_without_truncation)
          SecureRandom.expects(:hex).returns(hash)
          Socket.expects(:gethostname).returns(hostname)
          ShopifyCLI::DB.expects(:set).with(host_theme_name: host_theme_name)

          # When/Then
          assert_equal(host_theme_name, @host_theme.name)
        end

        def test_name_is_generated_unless_exists_in_db
          hostname = "theme-dev.lan"
          hash = "5676d"
          host_theme_name = "App Ext. Host (#{hash}-#{hostname.split(".").shift})"

          ShopifyCLI::DB.stubs(:get).with(:host_theme_name).returns(nil)
          SecureRandom.expects(:hex).returns(hash)
          Socket.expects(:gethostname).returns(hostname)
          ShopifyCLI::DB.expects(:set).with(host_theme_name: host_theme_name)

          assert_equal(host_theme_name, @host_theme.name)
        end
      end
    end
  end
end
