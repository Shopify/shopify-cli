# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    class ProjectTypeDefaultConfigurationTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_loads_all_extension_types_within_types_folder
        extension_type_count = 3
        assert_equal extension_type_count, Extension.specifications.each.count
      end

      def test_all_type_identifiers_are_defined_and_uppercase
        Extension.specifications.each do |type|
          refute_nil type.identifier
          assert_equal type.identifier.upcase, type.identifier
          refute_empty type.identifier.strip
        end
      end

      def test_all_type_names_are_defined
        Extension.specifications.each do |type|
          refute_empty type.name.strip
        end
      end
    end
  end
end
