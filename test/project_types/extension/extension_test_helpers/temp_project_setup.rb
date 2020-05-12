# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TempProjectSetup
      include ExtensionTestHelpers::TestExtensionSetup

      def setup_temp_project(
        api_key: 'TEST_KEY',
        api_secret: 'TEST_SECRET',
        title: 'Test',
        type: @test_extension_type,
        registration_id: 55)

        @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
        @api_key = api_key
        @api_secret = api_secret
        @title = title
        @type = type
        @registration_id = registration_id

        FileUtils.cd(@context.root)
        ExtensionProject.write_cli_file(context: @context, type: @type.identifier)
        ExtensionProject.write_env_file(
          context: @context,
          api_key: @api_key,
          api_secret: @api_secret,
          title: @title,
          registration_id: @registration_id
        )

        @project = ExtensionProject.current
      end
    end
  end
end
