# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TestExtensionSetup
      class SpecificationTestRepository
        def get(identifier)
          Extension::Result.ok(identifier == test_extension[:identifier] ? test_extension : nil)
        end

        def all
          Extension::Result.ok([test_extension])
        end

        private

        def test_extension
          { identifier: 'TEST_EXTENSION', name: 'Test Extension' }
        end
      end

      def setup
        ShopifyCli::ProjectType.load_type(:extension)
        @original_specification_repository = Extension::Specifications.repository
        Extension::Specifications.repository = SpecificationTestRepository.new

        @test_extension_type = ExtensionTestHelpers::TestExtension.new
        Models::Type.repository[@test_extension_type.identifier] = @test_extension_type
        super
      end

      def teardown
        super
        Models::Type.repository.delete(ExtensionTestHelpers::TestExtension::IDENTIFIER)
        Extension::Specifications.repository = @original_specification_repository
      end
    end
  end
end
