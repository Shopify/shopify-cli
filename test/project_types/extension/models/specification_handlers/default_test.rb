# typed: ignore
# frozen_string_literal: true
require "test_helper"
require "project_types/extension/extension_test_helpers"

module Extension
  module Models
    module SpecificationHandlers
      class DefaultTest < MiniTest::Test
        include ExtensionTestHelpers::TestExtensionSetup

        def test_tagline_returns_empty_string_if_not_defined_in_content
          base_type = Default.new(specification)
          base_type.stubs(:identifier).returns("INVALID")

          assert_equal "", base_type.tagline
        end

        def test_valid_extension_contexts_returns_empty_array
          assert_empty(Default.new(specification).valid_extension_contexts)
        end

        def test_extension_context_returns_nil
          assert_nil(Default.new(specification).extension_context(@context))
        end

        def test_graphql_identifier_is_upcased
          assert_equal specification.identifier.upcase, Default.new(specification).graphql_identifier
        end

        def test_name_defaults_to_specification_name
          assert_equal "Test Extension", @test_extension_type.name
        end

        def test_name_can_be_overriden_using_messages
          Messages::TYPES.merge!({
            test_extension: {
              name: "Overridden Name",
            },
          })
          assert_equal "Overridden Name", @test_extension_type.name
        ensure
          Messages::TYPES.delete(:test_extension)
        end

        private

        def specification
          Models::Specification.new(identifier: "test_extension")
        end
      end
    end
  end
end
