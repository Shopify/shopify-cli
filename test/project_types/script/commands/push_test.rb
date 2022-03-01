# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @directory = Dir.pwd
        @title = "title"
        @api_key = "apikey"
        @uuid = "uuid"
        @secret = "shh"
        @force = true
        @config = {
          "project_type" => "script",
          "organization_id" => 1,
          "extension_point_type" => "payment_methods",
          "title" => @title,
          "language" => "typescript",
        }

        @env = ShopifyCLI::Resources::EnvFile.new(api_key: @api_key, secret: @secret, extra: { "UUID" => @uuid })
        # @env_content = ShopifyCLI::Resources::EnvFile.read(@env)
        @script_project_repo = TestHelpers::FakeScriptProjectRepository.new
        @script_project_repo.create(
          language: "typescript",
          extension_point_type: "discount",
          title: "title",
          env: @env
        )
        @script_project = @script_project_repo.get

        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call).with(@context, :script).returns(true)
      end

      def test_call_connects_the_script_to_an_app_when_not_connected_and_interactive_environment
        # Given
        ShopifyCLI::Environment.stubs(:interactive?).returns(true)
        Layers::Application::ConnectApp.expects(:call).with(ctx: @context)
        Script::Loaders::Project
          .expects(:load)
          .with(
            directory: @directory,
            api_key: @api_key,
            api_secret: @secret,
            uuid: @uuid
          )
          .returns(@script_project)
        Layers::Application::PushScript
          .expects(:call)
          .with(ctx: @context, force: @force, project: @script_project)

        # When/Then
        perform_command_with_flags
      end

      def test_call_doesnt_connect_the_script_if_the_environment_is_not_interactive
        # Given
        ShopifyCLI::Environment.stubs(:interactive?).returns(false)
        Layers::Application::ConnectApp.expects(:call).never
        Script::Loaders::Project
          .expects(:load)
          .with(
            directory: @directory,
            api_key: @api_key,
            api_secret: @secret,
            uuid: @uuid
          )
          .returns(@script_project)
        Layers::Application::PushScript
          .expects(:call)
          .with(ctx: @context, force: @force, project: @script_project)

        # When/Then
        perform_command_with_flags
      end

      def test_call_formats_errors_through_the_error_handler
        # Given
        ShopifyCLI::Environment.stubs(:interactive?).returns(true)
        Layers::Application::ConnectApp.expects(:call).with(ctx: @context)
        Script::Loaders::Project
          .expects(:load)
          .with(
            directory: @directory,
            api_key: @api_key,
            api_secret: @secret,
            uuid: @uuid
          )
          .returns(@script_project)
        error = StandardError.new("Error")
        Layers::Application::PushScript
          .expects(:call)
          .with(ctx: @context, force: @force, project: @script_project)
          .raises(error)
        UI::ErrorHandler
          .expects(:pretty_print_and_raise)
          .with(error, failed_op: @context.message("script.push.error.operation_failed"))

        # When/Then
        perform_command_with_flags
      end

      def test_call_aborts_if_uuid_isnt_present
        # Given
        @uuid = ""
        ShopifyCLI::Environment.stubs(:interactive?).returns(false)
        Script::Loaders::Project
          .expects(:load)
          .with(
            directory: @directory,
            api_key: @api_key,
            api_secret: @secret,
            uuid: @uuid
          )
          .returns(@script_project)
        UI::ErrorHandler
          .expects(:pretty_print_and_raise)

        # When/Then
        perform_command_with_flags
      end

      def test_help
        ShopifyCLI::Context
          .expects(:message)
          .with("script.push.help", ShopifyCLI::TOOL_NAME)
        Script::Command::Push.help
      end

      private

      def perform_command
        capture_io { run_cmd("script push #{@force ? "--force" : ""}") }
      end

      def perform_command_with_flags
        capture_io do
          run_cmd("script push --api-key=#{@api_key} --api-secret=#{@secret} \
            --uuid=#{@uuid} #{@force ? "--force" : ""}")
        end
      end
    end
  end
end
