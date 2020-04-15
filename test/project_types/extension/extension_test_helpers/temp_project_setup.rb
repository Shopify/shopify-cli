module Extension
  module ExtensionTestHelpers
    module TempProjectSetup
      def setup_temp_project(api_key: 'TEST_KEY', api_secret: 'test_secret', type: 'TEST_EXTENSION')
        @context = TestHelpers::FakeContext.new(root: Dir.mktmpdir)
        @api_key = api_key
        @api_secret = api_secret
        @type = type

        ShopifyCli::ProjectType.load_type(:extension)
        FileUtils.cd(@context.root)
        ExtensionProject.write_project_files(context: @context, api_key: @api_key, api_secret: @api_secret, type: @type)

        @project = ExtensionProject.current
      end
    end
  end
end
