# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TestExtensionSetup
      include ExtensionTestHelpers::Content
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def test_prints_help
        io = capture_io { run_cmd('create extension --help') }
        confirm_content_output(io: io, expected_content: [Extension::Commands::Create.help])
      end

      def test_runs_type_create_and_writes_project_files
        name = "My Ext"
        directory_name = 'my_ext'
        app = Models::App.new(api_key: '1234', secret: '4567')
        stub_get_organizations([organization(name: "Organization One", apps: [app])])

        @test_extension_type.expects(:create).with(directory_name, @context).once
        ExtensionProject.expects(:write_project_files).with(
          context: @context,
          api_key: app.api_key,
          api_secret: app.secret,
          title: name,
          type: @test_extension_type.identifier
        ).once
        ShopifyCli::Core::Finalize.expects(:request_cd).with(directory_name).once

        io = capture_io do
          Commands::Create.ctx = @context
          arguments = %W(extension --name=#{name} --type=#{@test_extension_type.identifier} --api-key=#{app.api_key})
          Commands::Create.call(arguments, 'create', 'create')
        end

        confirm_content_output(io: io, expected_content: [
          Content::Create::READY_TO_START % name,
          Content::Create::LEARN_MORE % @test_extension_type.name
        ])
      end
    end
  end
end
