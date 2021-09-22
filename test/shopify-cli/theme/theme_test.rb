# frozen_string_literal: true
require "test_helper"
require "shopify_cli/theme/theme"

module ShopifyCLI
  module Theme
    class ThemeTest < Minitest::Test
      def setup
        super
        root = ShopifyCLI::ROOT + "/test/fixtures/theme"
        @ctx = TestHelpers::FakeContext.new(root: root)
        @theme = Theme.new(@ctx, root: root, id: "123")
      end

      def test_static_assets
        assert_includes(@theme.static_asset_paths, Pathname.new("assets/theme.css"))
      end

      def test_theme_files
        assert_includes(@theme.theme_files.map(&:relative_path), Pathname.new("layout/theme.liquid"))
        assert_includes(@theme.theme_files.map(&:relative_path), Pathname.new("templates/blog.json"))
        assert_includes(@theme.theme_files.map(&:relative_path), Pathname.new("locales/en.default.json"))
        assert_includes(@theme.theme_files.map(&:relative_path), Pathname.new("assets/theme.css"))
        assert_includes(@theme.theme_files.map(&:relative_path), Pathname.new("assets/theme.js"))
      end

      def test_get_file
        assert_equal(Pathname.new("layout/theme.liquid"), @theme["layout/theme.liquid"].relative_path)
        assert_equal(Pathname.new("layout/theme.liquid"),
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
    end
  end
end
