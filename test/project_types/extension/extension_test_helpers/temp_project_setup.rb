# frozen_string_literal: true
module Extension
  module ExtensionTestHelpers
    module TempProjectSetup
      include TestHelpers::Partners
      include ExtensionTestHelpers
      include ExtensionTestHelpers::TestExtensionSetup

      def setup_temp_project(
        api_key: "TEST_KEY",
        api_secret: "TEST_SECRET",
        title: "Test",
        type_identifier: @test_extension_type.identifier,
        registration_id: 55,
        registration_uuid: nil
      )

        @context = TestHelpers::FakeContext.new(root: "/fake/root")
        @api_key = api_key
        @api_secret = api_secret
        @title = title
        @type = type_identifier
        @registration_id = registration_id
        @registration_uuid = registration_uuid

        @project = FakeExtensionProject.new(
          api_key: @api_key,
          api_secret: @api_secret,
          title: @title,
          type: @type,
          registration_id: @registration_id,
          registration_uuid: @registration_uuid,
        )

        ShopifyCLI::Project.stubs(:current).returns(@project)
        ShopifyCLI::Project.stubs(:has_current?).returns(true)
        ExtensionProject.stubs(:current).returns(@project)
        specifications = DummySpecifications.build(
          identifier: type_identifier.downcase,
          custom_handler_root: File.expand_path("../", __FILE__),
          custom_handler_namespace: ::Extension::ExtensionTestHelpers,
        )
        Models::Specifications.stubs(:new).returns(specifications)
      end
    end
  end
end
