# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TempProjectSetup
      include TestHelpers::Partners
      include ExtensionTestHelpers::TestExtensionSetup

      def setup_temp_project(
        api_key: 'TEST_KEY',
        api_secret: 'TEST_SECRET',
        title: 'Test',
        type_identifier: @test_extension_type.identifier,
        registration_id: 55)

        @context = TestHelpers::FakeContext.new(root: '/fake/root')
        @api_key = api_key
        @api_secret = api_secret
        @title = title
        @type = type_identifier
        @registration_id = registration_id

        @project = FakeExtensionProject.new(
          api_key: @api_key,
          api_secret: @api_secret,
          title: @title,
          type: @type,
          registration_id: @registration_id
        )

        ExtensionProject.stubs(:current).returns(@project)
      end
    end
  end
end
