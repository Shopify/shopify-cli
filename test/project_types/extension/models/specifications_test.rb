require "test_helper"

module Extension
  module ExtensionTestHelpers; end

  module Models
    class SpecificationsTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_only_requires_fetching_strategy_for_initialization
        assert_nothing_raised { Specifications.new(fetch_specifications: -> { [] }) }
      end

      def test_supports_retrieving_all_specification_handlers
        specifications = build_specifications_domain(
          specifications: { identifier: "test_extension" }
        )
        assert_kind_of(SpecificationHandlers::Default, specifications["TEST_EXTENSION"])
      end

      def test_supports_retrieving_an_individual_specification_handler
        specifications = build_specifications_domain(
          specifications: { identifier: "test_extension" }
        )
        assert specifications.each.to_a.all? do |handler|
          handler.is_a?(SpeficiationHandlers::Default)
        end
      end

      private

      def build_specifications_domain(specifications:)
        Specifications.new(
          custom_handler_root: File.expand_path("../../extension_test_helpers/", __FILE__),
          custom_handler_namespace: ::Extension::ExtensionTestHelpers,
          fetch_specifications: -> { [specifications] }
        )
      end
    end
  end
end
