# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Models
    class TypesTest < MiniTest::Test
      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_loads_all_extension_types_within_types_folder
        extension_type_count = 1
        assert_equal extension_type_count, Models::Type.repository.size
      end

      def test_all_type_identifiers_are_defined_and_uppercase
        Models::Type.repository.values.each do |type|
          refute_nil type.identifier
          assert_equal type.identifier.upcase, type.identifier
          refute_empty type.identifier.strip
        end
      end

      def test_all_type_identifiers_are_accessible_as_class_or_instance_methods
        Models::Type.repository.values.each do |type|
          assert_equal type.class::IDENTIFIER, type.identifier
        end
      end

      def test_all_type_names_are_defined
        Models::Type.repository.values.each do |type|
          refute_empty type.name.strip
        end
      end
    end
  end
end
