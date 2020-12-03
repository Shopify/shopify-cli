# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Tasks
    module Converters
      class TypeDeclarationConverterTest < MiniTest::Test
        include TestHelpers::FakeUI
        include ExtensionTestHelpers::Messages

        def setup
          super
          ShopifyCli::ProjectType.load_type(:extension)

          @type = 'fake_type'
          @name = 'fake_name'
        end

        def test_from_array_aborts_with_a_parse_error_if_the_array_is_not_an_array
          io = capture_io_and_assert_raises(ShopifyCli::Abort) do
            Converters::TypeDeclarationConverter.from_array(@context, nil)
          end

          assert_message_output(io: io, expected_content: @context.message('tasks.errors.parse_error'))
        end

        def test_from_hash_aborts_with_a_parse_error_if_the_hash_is_not_a_hash
          io = capture_io_and_assert_raises(ShopifyCli::Abort) do
            Converters::TypeDeclarationConverter.from_hash(@context, nil)
          end

          assert_message_output(io: io, expected_content: @context.message('tasks.errors.parse_error'))
        end

        def test_from_hash_parses_a_type_declaration_from_a_hash
          hash = {
            Converters::TypeDeclarationConverter::TYPE_FIELD => @type,
            Converters::TypeDeclarationConverter::NAME_FIELD => @name,
          }

          parsed_type_declaration = Converters::TypeDeclarationConverter.from_hash(@context, hash)

          assert_kind_of(Models::TypeDeclaration, parsed_type_declaration)
          assert_equal @type.to_sym, parsed_type_declaration.type
          assert_equal @name, parsed_type_declaration.name
        end

        def test_from_array_parses_a_type_declarations_from_a_hash
          array = [
            {
              Converters::TypeDeclarationConverter::TYPE_FIELD => @type,
              Converters::TypeDeclarationConverter::NAME_FIELD => @name,
            },
            {
              Converters::TypeDeclarationConverter::TYPE_FIELD => 'fake_type2',
              Converters::TypeDeclarationConverter::NAME_FIELD => 'fake_name2',
            }
          ]

          parsed_type_declarations = Converters::TypeDeclarationConverter.from_array(@context, array)

          assert_equal 2, parsed_type_declarations.count
          assert parsed_type_declarations.any? { |declaration| declaration.type == @type.to_sym }
          assert parsed_type_declarations.any? { |declaration| declaration.type == :fake_type2 }
        end
      end
    end
  end
end
