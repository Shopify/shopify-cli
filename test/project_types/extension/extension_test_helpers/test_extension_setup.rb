# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TestExtensionSetup
      def setup
        ShopifyCli::ProjectType.load_type(:extension)

        @_original_extension_specifications = Extension.specifications

        Extension.specifications = Models::Specifications.new(
          custom_handler_root: File.expand_path('../', __FILE__),
          custom_handler_namespace: ::Extension::ExtensionTestHelpers,
          fetch_specifications: -> { [{ identifier: 'test_extension' }] }
        )
        @test_extension_type = Extension.specifications['TEST_EXTENSION']

        super
      end

      def teardown
        super
        Extension.specifications = @_original_extension_specifications
      end
    end
  end
end
