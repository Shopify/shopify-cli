# frozen_string_literal: true
require "test_helper"
require "shopify-cli/theme/dev_server"

class ThemeTest < Minitest::Test
  def test_uses_development_environment_by_default
    config = ShopifyCli::Theme::DevServer::Config.from_path(ShopifyCli::ROOT + "/test/fixtures/theme")

    assert_equal("123456789", config.theme_id)
  end

  def test_uses_another_environment_if_specified
    config = ShopifyCli::Theme::DevServer::Config.from_path(
      ShopifyCli::ROOT + "/test/fixtures/theme",
      environment: "staging"
    )

    assert_equal("567891234", config.theme_id)
  end
end
