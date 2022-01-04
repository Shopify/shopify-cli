# typed: ignore
require "test_helper"

module Extension
  module Models
    module ServerConfig
      class DevelopmentTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_server_config_development_can_be_instantiated_with_valid_attributes
          assert_nothing_raised do
            ServerConfig::Development.new(
              build_dir: "test",
              root_dir: "test",
              template: "javascript",
              renderer: renderer,
              entries: entries,
            )
          end
        end

        def test_invalild_template_raises_error
          assert_raises SmartProperties::Error do
            ServerConfig::Development.new(
              build_dir: "test",
              root_dir: "test",
              template: "invalid",
              renderer: renderer,
              entries: entries,
            )
          end
        end

        private

        def renderer
          ServerConfig::DevelopmentRenderer.new(name: "@shopify/checkout-ui-extensions")
        end

        def entries
          ServerConfig::DevelopmentEntries.new(main: "src/index.js")
        end
      end
    end
  end
end
