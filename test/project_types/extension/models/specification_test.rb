# typed: ignore
require "test_helper"

module Extension
  module Models
    class SpecificationTest < MiniTest::Test
      def setup
        super
        ShopifyCLI::ProjectType.load_type(:extension)
      end

      def test_can_be_instantiated_from_a_set_of_valid_attributes
        assert_nothing_raised do
          Specification.new(**valid_attributes)
        end
      end

      def test_specification_requires_an_identifier
        assert_raises SmartProperties::Error do
          Specification.new(**valid_attributes.tap { |attrs| attrs.delete(:identifier) })
        end
      end

      def test_argo_feature_is_represented_by_dedicated_domain_object
        Specification.new(**valid_attributes).tap do |s|
          assert_kind_of(Specification::Features::Argo, s.features.argo)
        end
      end

      def test_argo_feature_requires_surface_area
        invalid_attributes = valid_attributes.tap do |attrs|
          attrs[:features][:argo].delete(:surface)
        end

        assert_raises SmartProperties::Error do
          Specification.new(**invalid_attributes)
        end
      end

      def test_argo_feature_requires_git_template
        invalid_attributes = valid_attributes.tap do |attrs|
          attrs[:features][:argo].delete(:git_template)
        end

        assert_raises SmartProperties::Error do
          Specification.new(**invalid_attributes)
        end
      end

      def test_argo_feature_requires_renderer_package_name
        invalid_attributes = valid_attributes.tap do |attrs|
          attrs[:features][:argo].delete(:renderer_package_name)
        end

        assert_raises SmartProperties::Error do
          Specification.new(**invalid_attributes)
        end
      end

      def test_unknown_features_are_represented_by_an_open_struct
        valid_attributes_with_extra_feature = valid_attributes.tap do |attrs|
          attrs[:features].merge!({
            extra_feature: {
              some_config_value: 1,
            },
          })
        end

        Specification.new(**valid_attributes_with_extra_feature).tap do |s|
          assert_kind_of(OpenStruct, s.features.extra_feature)
          assert_equal 1, s.features.extra_feature.some_config_value
        end
      end

      private

      def valid_attributes
        {
          identifier: "test_extension",
          features: {
            argo: {
              surface: "admin",
              git_template: "https://github.com/Shopify/argo-test-template.git",
              renderer_package_name: "@shopify/argo-test",
            },
          },
        }
      end
    end
  end
end
