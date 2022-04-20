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
              name: "@shopify/checkout-ui-extensions",
              version: "~> 0.1.0"
            )
          end
        end

        def test_version_fallback_is_latest
          ServerConfig::DevelopmentRenderer.new(name: "@shopify/checkout-ui-extensions",).tap do |renderer|
            assert_equal "latest", renderer.version
          end
        end

        def test_find_sets_specific_versions
          %w[product_subscription checkout_ui_extension checkout_post_purchase pos_ui_extension].each do |type|
            renderer = ServerConfig::DevelopmentRenderer.find(type)
            refute_nil renderer
            refute_equal("latest", renderer.version)
            refute_empty renderer.version
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
