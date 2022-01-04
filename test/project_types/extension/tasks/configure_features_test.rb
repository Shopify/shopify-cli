# typed: ignore
module Extension
  module Tasks
    class ConfigureFeaturesTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_configures_git_template
        result = ConfigureFeatures.call(build_set_of_specification_attributes)
        assert result.value.all? do |attrs|
          attrs[:features][:argo].keys.include?(:git_template)
        end
      end

      def test_configures_renderer_package_name
        result = ConfigureFeatures.call(build_set_of_specification_attributes)
        assert result.value.all? do |attrs|
          attrs[:features][:argo].keys.include?(:renderer_package_name)
        end
      end

      def test_fails_when_surface_is_unknown
        result = ConfigureFeatures
          .call(build_set_of_specification_attributes(surface: "unknown"))
        assert_predicate(result, :failure?)
        assert_kind_of(ConfigureFeatures::UnknownSurfaceArea, result.error)
      end

      def test_fails_when_surface_is_unspecified
        attributes = build_set_of_specification_attributes.tap do |attrs|
          attrs.first[:features][:argo].delete(:surface)
        end
        result = ConfigureFeatures.call(attributes)
        assert_predicate(result, :failure?)
        assert_kind_of(ConfigureFeatures::UnspecifiedSurfaceArea, result.error)
      end

      def test_correct_git_template_for_admin_extensions
        set_of_attributes = build_set_of_specification_attributes(surface: "admin")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal(
          "https://github.com/Shopify/admin-ui-extensions-template",
          result.value.dig(0, :features, :argo, :git_template)
        )
      end

      def test_correct_renderer_package_name_for_admin_extensions
        set_of_attributes = build_set_of_specification_attributes(surface: "admin")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal "@shopify/admin-ui-extensions", result.value.dig(0, :features, :argo, :renderer_package_name)
      end

      def test_correct_git_template_for_checkout_extensions
        set_of_attributes = build_set_of_specification_attributes(surface: "checkout")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal(
          "https://github.com/Shopify/checkout-ui-extensions-template",
          result.value.dig(0, :features, :argo, :git_template)
        )
      end

      def test_correct_renderer_package_name_for_checkout_extensions
        set_of_attributes = build_set_of_specification_attributes(surface: "checkout")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal "@shopify/checkout-ui-extensions", result.value.dig(0, :features, :argo, :renderer_package_name)
      end

      private

      def build_set_of_specification_attributes(surface: "admin")
        [{
          identifier: "test_extension",
          features: {
            argo: {
              surface: surface,
            },
          },
        }]
      end
    end
  end
end
