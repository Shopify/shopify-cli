# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Models
    class TypeDeclarationTest < MiniTest::Test
      include Extension::ExtensionTestHelpers::TestExtensionSetup

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_load_type_loads_the_relevant_type_class
        assert_kind_of Extension::ExtensionTestHelpers::TestExtension, @test_extension_declaration.load_type
      end

      def test_load_type_memoizes_the_type_class
        Models::Type.expects(:load_type).returns(Extension::ExtensionTestHelpers::TestExtension.new).once

        @test_extension_declaration.load_type
        @test_extension_declaration.load_type
        @test_extension_declaration.load_type
      end
    end
  end
end
