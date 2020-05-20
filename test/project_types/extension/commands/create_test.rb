# frozen_string_literal: true
require 'test_helper'
require 'project_types/extension/extension_test_helpers'

module Extension
  module Commands
    class CreateTest < MiniTest::Test
      include TestHelpers::FakeUI
      include ExtensionTestHelpers::TestExtensionSetup
      include ExtensionTestHelpers::Messages
      include ExtensionTestHelpers::Stubs::GetOrganizations

      def test_prints_help
        io = capture_io { run_cmd('create extension --help') }
        assert_message_output(io: io, expected_content: [Extension::Commands::Create.help])
      end

      def test_runs_type_create_and_writes_project_files
        name = "My Ext"
        directory_name = 'my_ext'

        @test_extension_type.expects(:create).with(directory_name, @context).once
        ExtensionProject.expects(:write_cli_file).with(context: @context, type: @test_extension_type.identifier).once
        ExtensionProject.expects(:write_env_file).with(context: @context, title: name).once

        io = capture_io do
          Commands::Create.ctx = @context
          arguments = %W(extension --name=#{name} --type=#{@test_extension_type.identifier})
          Commands::Create.call(arguments, 'create', 'create')
        end

        assert_message_output(io: io, expected_content: [
          @context.message('create.ready_to_start', name, directory_name),
          @context.message('create.learn_more', @test_extension_type.name)
        ])
      end

      def test_help_does_not_load_extension_project_type
        io = capture_io do
          run_cmd('create --help')
        end
        output = io.join
        refute_match('extension', output)
      end
    end
  end
end
