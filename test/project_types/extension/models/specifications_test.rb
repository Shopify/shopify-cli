require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module ExtensionTestHelpers; end

  module Models
    class SpecificationsTest < MiniTest::Test
      include ExtensionTestHelpers

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_only_requires_fetching_strategy_for_initialization
        assert_nothing_raised { Specifications.new(fetch_specifications: -> { [] }) }
      end

      def test_returns_default_specification_handler_as_fallback
        specifications = DummySpecifications.build(surface: "checkout")
        assert_kind_of(SpecificationHandlers::Default, specifications["TEST_EXTENSION"])
      end

      def test_returns_argo_admin_specific_specification_handler
        specifications = DummySpecifications.build(surface: "admin")
        assert_kind_of(SpecificationHandlers::Argo, specifications["TEST_EXTENSION"])
      end

      def test_supports_retrieving_an_individual_specification_handler
        specifications = DummySpecifications.build
        assert specifications.each.to_a.all? do |handler|
          handler.is_a?(SpeficiationHandlers::Default)
        end
      end
    end
  end
end
