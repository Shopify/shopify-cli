require "test_helper"

module Extension
  module Models
    module ServerConfig
      class DevelopmentRendererTest < MiniTest::Test
        def setup
          super
          ShopifyCLI::ProjectType.load_type(:extension)
        end

        def test_extension_config_renderer_can_be_instantiated_with_valid_attributes
          assert_nothing_raised do
            ServerConfig::DevelopmentRenderer.new(
              name: "@shopify/checkout-ui-extensions"
            )
          end
        end

        def test_invalid_renderer_name_raises_error
          assert_raises SmartProperties::Error do
            ServerConfig::DevelopmentRenderer.new(
              name: "invalid"
            )
          end
        end
      end
    end
  end
end
