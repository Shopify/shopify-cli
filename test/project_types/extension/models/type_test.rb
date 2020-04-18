# frozen_string_literal: true
require 'test_helper'

module Extension
  module Models
    class TypeTest < MiniTest::Test
      include ExtensionTestHelpers::TestExtensionSetup

      def test_loads_all_extension_types_within_types_folder
        production_extension_type_count = 2
        test_extension_type_count = 1
        total_extension_type_count = production_extension_type_count + test_extension_type_count

        assert_equal total_extension_type_count, Models::Type.repository.size
      end

      def test_can_load_type_by_identifier
        assert_equal @test_extension_type.identifier, Models::Type.load_type(@test_extension_type.identifier).identifier
      end

      def test_valid_determines_if_a_type_is_valid
        assert Models::Type.valid?(@test_extension_type.identifier)
        refute Models::Type.valid?('INVALID')
      end

      def test_all_identifiers_are_defined_and_uppercase
        Models::Type.repository.values.each do |type|
          assert_equal type.identifier.upcase, type.identifier
          refute_empty type.identifier.strip
        end
      end

      def test_all_names_are_defined
        Models::Type.repository.values.each do |type|
          refute_empty type.name.strip
        end
      end

      def test_raises_not_implemented_error_for_required_methods
        assert_raises(NotImplementedError) { Models::Type.new.identifier }
        assert_raises(NotImplementedError) { Models::Type.new.name }
        assert_raises(NotImplementedError) { Models::Type.new.config(@context) }
      end

      def test_valid_extension_contexts_returns_empty_array
        assert_empty Models::Type.new.valid_extension_contexts
      end

      def test_extension_context_returns_nil
        assert_nil Models::Type.new.extension_context(@context)
      end
    end
  end
end
