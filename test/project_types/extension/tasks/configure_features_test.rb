module Extension
  module Tasks
    class ConfigureFeaturesTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
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

      def test_fails_when_surface_area_is_unknown
        result = ConfigureFeatures
          .call(build_set_of_specification_attributes(surface_area: "unknown"))
        assert_predicate(result, :failure?)
        assert_kind_of(ConfigureFeatures::UnknownSurfaceArea, result.error)
      end

      def test_fails_when_surface_area_is_unspecified
        attributes = build_set_of_specification_attributes.tap do |attrs|
          attrs.first[:features][:argo].delete(:surface_area)
        end
        result = ConfigureFeatures.call(attributes)
        assert_predicate(result, :failure?)
        assert_kind_of(ConfigureFeatures::UnspecifiedSurfaceArea, result.error)
      end

      def test_correct_git_template_for_admin_extensions
        set_of_attributes = build_set_of_specification_attributes(surface_area: "admin")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal(
          "https://github.com/Shopify/argo-admin-template.git",
          result.value.dig(0, :features, :argo, :git_template)
        )
      end

      def test_correct_renderer_package_name_for_admin_extensions
        set_of_attributes = build_set_of_specification_attributes(surface_area: "admin")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal "@shopify/argo-admin", result.value.dig(0, :features, :argo, :renderer_package_name)
      end

      def test_correct_git_template_for_checkout_extensions
        set_of_attributes = build_set_of_specification_attributes(surface_area: "checkout")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal(
          "https://github.com/Shopify/argo-checkout-template.git",
          result.value.dig(0, :features, :argo, :git_template)
        )
      end

      def test_correct_renderer_package_name_for_checkout_extensions
        set_of_attributes = build_set_of_specification_attributes(surface_area: "checkout")
        result = ConfigureFeatures.call(set_of_attributes)
        assert_equal "@shopify/argo-checkout", result.value.dig(0, :features, :argo, :renderer_package_name)
      end

      private

      def build_set_of_specification_attributes(surface_area: "admin")
        [{
          identifier: "test_extension",
          features: {
            argo: {
              surface_area: surface_area,
            },
          },
        }]
      end
    end
  end
end
