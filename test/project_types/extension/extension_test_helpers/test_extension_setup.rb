# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TestExtensionSetup
      def setup
        ShopifyCli::ProjectType.load_type(:extension)

        @test_extension_type = ExtensionTestHelpers::TestExtension.new
        @test_extension_declaration = Models::TypeDeclaration.new(
          name: @test_extension_type.name,
          type: @test_extension_type.identifier
        )
        Models::Type.repository[@test_extension_type.identifier] = @test_extension_type
        super
      end

      def teardown
        super
        Models::Type.repository.delete(ExtensionTestHelpers::TestExtension::IDENTIFIER)
      end
    end
  end
end
