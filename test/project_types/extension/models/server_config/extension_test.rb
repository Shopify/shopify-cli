require "test_helper"

module Extension
  module Models
    module ServerConfig
      class ExtensionTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
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

        def test_extension_build_creates_expected_extension_config
          assert_nothing_raised do
            extension = ServerConfig::Extension.build(
              template: "javascript",
              type: "admin_ui_extension",
              root_dir: "test"
            )

            assert(true, extension.instance_of?(ServerConfig::Extension))
            assert_equal("src/index.js", extension.development.entries.main)
            assert_equal("@shopify/admin-ui-extensions", extension.development.renderer.name)
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
