# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class ThemeTest < Minitest::Test
  def setup
    super
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")
    @theme = ShopifyCli::Theme::DevServer::Theme.new(config)
  end

  def test_assets
    assert_includes(@theme.asset_paths, Pathname.new("assets/theme.css"))
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
      @theme[Pathname.new("#{ShopifyCli::ROOT}/test/fixtures//theme/layout/theme.liquid")].relative_path)
    assert_equal(@theme.theme_files.first, @theme[@theme.theme_files.first])
  end

  def test_is_theme_file
    assert(@theme.theme_file?(@theme["layout/theme.liquid"]))
    assert(@theme.theme_file?(@theme[Pathname.new(ShopifyCli::ROOT).join("test/fixtures/theme/layout/theme.liquid")]))
  end

  def test_ignores_file
    assert(@theme.ignore?(@theme["config/settings_data.json"]))
    assert(@theme.ignore?(@theme["config/super_secret.json"]))
    refute(@theme.ignore?(@theme["assets/theme.css"]))
  end
end
