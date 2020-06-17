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

      def setup
        super
        @name = "My Ext"
        @directory_name = 'my_ext'
      end

      def test_prints_help
        io = capture_io { run_cmd('create extension --help') }
        assert_message_output(io: io, expected_content: [Extension::Commands::Create.help])
      end

      def test_runs_type_create_and_writes_project_files
        @test_extension_type.expects(:create).with(@directory_name, @context).returns(true).once
        ExtensionProject.expects(:write_cli_file).with(context: @context, type: @test_extension_type.identifier).once
        ExtensionProject.expects(:write_env_file).with(context: @context, title: @name).once

        io = capture_io do
          run_create(%W(extension --name=#{@name} --type=#{@test_extension_type.identifier}))
        end

        assert_message_output(io: io, expected_content: [
          @context.message('create.ready_to_start', @directory_name, @name),
          @context.message('create.learn_more', @test_extension_type.name)
        ])
      end

      def test_does_not_create_project_files_and_outputs_try_again_message_if_type_create_failed
        @test_extension_type.expects(:create).with(@directory_name, @context).returns(false).once
        ExtensionProject.expects(:write_cli_file).never
        ExtensionProject.expects(:write_env_file).never

        io = capture_io do
          run_create(%W(extension --name=#{@name} --type=#{@test_extension_type.identifier}))
        end

        assert_message_output(io: io, expected_content: @context.message('create.try_again'))
      end

      def test_help_does_not_load_extension_project_type
        io = capture_io do
          run_create(%w(create --help))
        end

        output = io.join
        refute_match('extension', output)
      end

      private

      def run_create(arguments)
        Commands::Create.ctx = @context
        Commands::Create.call(arguments, 'create', 'create')
      end
    end
  end
end
