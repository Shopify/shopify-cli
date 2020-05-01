# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::Partners
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TestExtensionSetup
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def test_prints_help
        io = capture_io { run_cmd('create extension --help') }
        assert_match(CLI::UI.fmt(Extension::Commands::Create.help), io.join)
      end

      def test_clones_project_template
        name = "MyExt"

        ShopifyCli::Git
          .expects(:clone)
          .with('https://github.com/Shopify/shopify-app-extension-template.git', 'myext', ctx: @context)
          .add_side_effect(CreateFakeExtensionProject.new)

        JsDeps.expects(:install).add_side_effect(CreateDummyLockfile.new)
        ShopifyCli::Core::Finalize.expects(:request_cd).with('myext')
        stub_get_organizations([
          organization(name: "Organization One", apps: [Models::App.new(api_key: '1234', secret: '4567')])
        ])

        io = capture_io do
          run_cmd("create extension --name=#{name} --type=#{@test_extension_type.identifier} --api-key=1234")
        end

        refute File.exists?('myext/.git'), 'Expected .git directory to be removed'
        assert File.exists?('myext/yarn.lock'), 'Expected yarn.lock directory to be removed'

        assert_match Content::Create::READY_TO_START % name, io.join
        assert_match Content::Create::LEARN_MORE % @test_extension_type.name, io.join
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

