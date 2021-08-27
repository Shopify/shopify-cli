require "test_helper"

module Extension
  module Models
    module ServerConfig
      class ExtensionTest < MiniTest::Test
        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)
        end

        def test_extension_config_can_be_instantiated_with_valid_attributes
          assert_nothing_raised do
            ServerConfig::Extension.new(
              type: "checkout-ui-extension",
              uuid: "00000000-0000-0000-0000-000000000000",
              user: ServerConfig::User.new,
              development: development
            )
          end
        end

        private

        def development
          renderer = ServerConfig::DevelopmentRenderer.new(name: "@shopify/checkout-ui-extensions")
          entries = ServerConfig::DevelopmentEntries.new(main: "src/index.js")
          ServerConfig::Development.new(
            build_dir: "test",
            root_dir: "test",
            template: "javascript",
            renderer: renderer,
            entries: entries,
          )
        end
      end
    end
  end
end
