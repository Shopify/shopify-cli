# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/theme"
require "shopify_cli/theme/development_theme"

module ShopifyCLI
  module Theme
    class ThemeTest < Minitest::Test
      def setup
        super
        @root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: @root)
        @theme = Theme.new(@ctx, root: @root, id: "123")
      end

      def test_static_assets_with_subdirectory
        root = @root + "_with_subdirectories"
        ctx = TestHelpers::FakeContext.new(root: root)
        theme = Theme.new(ctx, root: root, id: "123")

        io = capture_io_and_assert_raises(ShopifyCLI::Abort) do
          theme.static_asset_paths
        end
        filepath = root + "/assets/assets_subdir"
        assert_message_output(io: io, expected_content: ctx.message("theme.serve.error.invalid_subdirectory", filepath))
      end

      def test_static_assets
        assert_includes(@theme.static_asset_paths, "assets/theme.css")
      end

      def test_theme_files
        assert_includes(@theme.theme_files.map(&:relative_path), "layout/theme.liquid")
        assert_includes(@theme.theme_files.map(&:relative_path), "templates/blog.json")
        assert_includes(@theme.theme_files.map(&:relative_path), "locales/en.default.json")
        assert_includes(@theme.theme_files.map(&:relative_path), "assets/theme.css")
        assert_includes(@theme.theme_files.map(&:relative_path), "assets/theme.js")
      end

      def test_get_file
        assert_equal("layout/theme.liquid", @theme["layout/theme.liquid"].relative_path)
        assert_equal("layout/theme.liquid",
          @theme[Pathname.new("#{ShopifyCLI::ROOT}/test/fixtures//theme/layout/theme.liquid")].relative_path)
        assert_equal(@theme.theme_files.first, @theme[@theme.theme_files.first])
      end

      def test_theme_file
        assert(@theme["layout/theme.liquid"].liquid?)
        refute(@theme["layout/theme.liquid"].json?)
        assert(@theme["templates/blog.json"].json?)
        assert(@theme["templates/blog.json"].template?)
        assert(@theme["locales/en.default.json"].json?)
        refute(@theme["locales/en.default.json"].template?)
      end

      def test_is_theme_file
        assert(@theme.theme_file?(@theme["layout/theme.liquid"]))
        assert(@theme.theme_file?(
          @theme[Pathname.new(ShopifyCLI::ROOT).join("test/fixtures/theme/layout/theme.liquid")]
        ))
      end

      def test_mime_type
        assert_equal("text/x-liquid", @theme["layout/theme.liquid"].mime_type.name)
        assert_equal("text/css", @theme["assets/theme.css"].mime_type.name)
      end

      def test_text
        assert(@theme["layout/theme.liquid"].mime_type.text?)
      end

      def test_checksum
        content = @theme["layout/theme.liquid"].read
        assert_equal(Digest::MD5.hexdigest(content), @theme["layout/theme.liquid"].checksum)
      end

      def test_normalize_json_template_for_checksum
        expected_content = <<~EOS
          {
            "name": "Blog",
            "sections": {
              "main": {
                "type": "main-blog",
                "settings": {}
              }
            },
            "order": [
              "main"
            ]
          }
        EOS
        normalized = JSON.parse(expected_content).to_json
        assert_equal(Digest::MD5.hexdigest(normalized), @theme["templates/blog.json"].checksum)
      end

      def test_normalize_settings_schema_for_checksum
        normalized =
          "[{\"name\":\"theme_info\",\"theme_name\":\"Example\"," \
          "\"theme_version\":\"1.0.0\",\"theme_author\":\"Shopify\"," \
          "\"theme_documentation_url\":\"https:\\/\\/shopify.com\"," \
          "\"theme_support_url\":\"https:\\/\\/support.shopify.com\\/\"}]"
        assert_equal(Digest::MD5.hexdigest(normalized), @theme["config/settings_schema.json"].checksum)
      end

      def test_read_binary_file
        file = @theme["assets/logo.png"]

        content = file.read
        assert_equal(file.path.size, content.bytesize)
      end

      def test_write_binary_file
        file = @theme["assets/logo.png"]
        new_file = @theme["assets/logo2.png"]

        begin
          new_file.write(file.read)
          assert_equal(file.path.size, new_file.path.size)
        ensure
          ::File.delete(new_file.path) if new_file.exist?
        end
      end

      def test_all
        mock_themes_json

        expected_ids = [4, 3, 5, 1]
        expected_names = %w(Export Development Venture Dawn)
        expected_roles = %w(unpublished development unpublished live)

        themes = Theme.all(@ctx, root: @root)

        assert_equal 4, themes.size
        assert_equal expected_ids, themes.map(&:id)
        assert_equal expected_names, themes.map(&:name)
        assert_equal expected_roles, themes.map(&:role)
      end

      def test_live
        mock_themes_json

        theme = Theme.live(@ctx, root: @root)

        assert_equal 1, theme.id
        assert_equal "Dawn", theme.name
        assert_equal "live", theme.role
        assert theme.live?
      end

      def test_development_when_expected_to_exist
        mock_themes_json
        dev_theme = DevelopmentTheme.new(@ctx, root: @root)
        dev_theme.stubs(:ensure_exists!).returns(dev_theme)
        dev_theme.stubs(:exists?).returns(true)
        dev_theme.stubs(:id).returns(3)

        DevelopmentTheme.stubs(:new).with(@ctx, root: @root).returns(dev_theme)

        theme = DevelopmentTheme.find_or_create!(@ctx, root: @root)

        assert_equal 3, theme.id
        assert_match("Development", theme.name)
        assert_equal "development", theme.role
        assert theme.development?
      end

      def test_development_when_does_not_exist
        ShopifyCLI::DB.stubs(:get).with(:development_theme_id).returns(nil)

        theme = DevelopmentTheme.find(@ctx, root: @root)

        assert_nil theme
      end

      def test_find_by_identifier_with_id
        mock_themes_json

        theme = Theme.find_by_identifier(@ctx, root: @root, identifier: "5")

        assert_equal 5, theme.id
        assert_equal "Venture", theme.name
        assert_equal "unpublished", theme.role
      end

      def test_find_by_identifier_with_name
        mock_themes_json

        theme = Theme.find_by_identifier(@ctx, root: @root, identifier: "Venture")

        assert_equal 5, theme.id
        assert_equal "Venture", theme.name
        assert_equal "unpublished", theme.role
      end

      def test_find_by_identifier_when_theme_is_not_found
        mock_themes_json
        assert_nil Theme.find_by_identifier(@ctx, root: @root, identifier: "Other")
      end

      private

      def mock_themes_json
        AdminAPI.stubs(:get_shop_or_abort).returns("shop.myshopify.com")
        AdminAPI.stubs(:rest_request).returns([
          200,
          {
            "themes" => [
              {
                "id" => 1,
                "name" => "Dawn",
                "created_at" => "2021-01-01T12:30:59+01:00",
                "updated_at" => "2021-01-02T12:30:59+01:00",
                "role" => "main",
                "theme_store_id" => 2,
                "previewable" => true,
                "processing" => false,
                "admin_graphql_api_id" => "gid://shopify/Theme/7",
              },
              {
                "id" => 5,
                "name" => "Venture",
                "created_at" => "2021-01-03T12:30:59+01:00",
                "updated_at" => "2021-01-04T12:30:59+01:00",
                "role" => "unpublished",
                "theme_store_id" => 6,
                "previewable" => true,
                "processing" => false,
                "admin_graphql_api_id" => "gid://shopify/Theme/8",
              },
              {
                "id" => 3,
                "name" => "Development",
                "created_at" => "2021-01-05T12:30:59+01:00",
                "updated_at" => "2021-01-06T12:30:59+01:00",
                "role" => "development",
                "theme_store_id" => nil,
                "previewable" => true,
                "processing" => false,
                "admin_graphql_api_id" => "gid://shopify/Theme/9",
              },
              {
                "id" => 4,
                "name" => "Export",
                "created_at" => "2021-01-07T12:30:59+01:00",
                "updated_at" => "2021-01-08T12:30:59+01:00",
                "role" => "unpublished",
                "theme_store_id" => nil,
                "previewable" => true,
                "processing" => false,
                "admin_graphql_api_id" => "gid://shopify/Theme/10",
              },
            ],
          },
        ])
      end
    end
  end
end
