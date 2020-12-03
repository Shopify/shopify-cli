# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Tasks
    class GetTypeDeclarationsTest < MiniTest::Test
      include TestHelpers::Partners
      include ExtensionTestHelpers::Stubs::GetTypeDeclarations

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)

        @type_declaration1 = Models::TypeDeclaration.new(type: :fake_type1, name: 'Fake Type 1')
        @type_declaration2 = Models::TypeDeclaration.new(type: :fake_type2, name: 'Fake Type 2')
        @declarations = [@type_declaration1, @type_declaration2]
      end

      def test_loads_all_type_declarations
        stub_get_type_declarations(@declarations)

        type_declarations_list = Tasks::GetTypeDeclarations.call(context: @context)

        first = type_declarations_list.find { |declaration| declaration.type == @type_declaration1.type }
        assert_equal @type_declaration1.name, first.name

        second = type_declarations_list.find { |declaration| declaration.type == @type_declaration2.type }
        assert_equal @type_declaration2.name, second.name
      end

      def test_returns_empty_array_if_there_are_no_type_declarations
        stub_get_type_declarations([])

        assert_empty(Tasks::GetTypeDeclarations.call(context: @context))
      end
    end
  end
end
