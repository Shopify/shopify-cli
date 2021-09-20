# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TestExtensionSetup
      def setup
        ShopifyCLI::ProjectType.load_type(:extension)

        specifications = DummySpecifications.build(
          custom_handler_root: File.expand_path("../", __FILE__),
          custom_handler_namespace: ::Extension::ExtensionTestHelpers,
        )
        @test_extension_type = specifications["TEST_EXTENSION"]

        super
      end
    end
  end
end
