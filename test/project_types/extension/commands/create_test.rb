# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def setup
        super
        ShopifyCli::ProjectType.load_type(:extension)
      end

      def test_prints_help
        io = capture_io { run_cmd('create extension --help') }
        assert_match(CLI::UI.fmt(Extension::Commands::Create.help), io.join)
      end

      def test_clones_project_template
        ShopifyCli::Git
          .expects(:clone)
          .with('https://github.com/Shopify/shopify-app-extension-template.git', 'myext')
          .add_side_effect(CreateFakeExtensionProject.new)

        JsDeps.expects(:install).add_side_effect(CreateDummyLockfile.new)
        ShopifyCli::Core::Finalize.expects(:request_cd).with('myext')
        stub_get_organizations

        capture_io { run_cmd('create extension --title=myext --type=product-details --api-key=1234') }
        refute File.exists?('myext/.git'), 'Expected .git directory to be removed'
        lockfile_content = File.read('myext/yarn.lock')
        assert_equal lockfile_content, '# Dummy lockfile'
      ensure
        FileUtils.rm_r('myext')
      end
    end
  end
end

class CreateFakeExtensionProject
  def perform
    FileUtils.mkdir_p('myext/.git')
    File.open('myext/package.json', 'w') { |f| f.puts('{}') }
    FileUtils.touch('myext/yarn.lock')
  end
end

class CreateDummyLockfile
  def perform
    File.open('myext/yarn.lock', "w") { |f| f.write("# Dummy lockfile") }
  end
end

