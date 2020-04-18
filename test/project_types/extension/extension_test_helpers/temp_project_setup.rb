# frozen_string_literal: true

module Extension
  module ExtensionTestHelpers
    module TempProjectSetup
      include ExtensionTestHelpers::TestExtensionSetup

      def setup_temp_project(api_key: 'TEST_KEY', api_secret: 'TEST_SECRET', type: @test_extension_type)
        @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
        @api_key = api_key
        @api_secret = api_secret
        @type = type

        FileUtils.cd(@context.root)
        ExtensionProject.write_project_files(
          context: @context,
          api_key: @api_key,
          api_secret: @api_secret,
          type: @type.identifier
        )

        @project = ExtensionProject.current
      end
    end
  end
end
