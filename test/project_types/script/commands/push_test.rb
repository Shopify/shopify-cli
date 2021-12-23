# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @script_name = "script_name"
        @api_key = "apikey"
        @uuid = "uuid"
        @secret = "shh"
        @force = true
        @config = {
          "project_type" => "script",
          "organization_id" => 1,
          "extension_point_type" => "payment_methods",
          "script_name" => @script_name,
          "language" => "assemblyscript",
        }

        @env = ShopifyCLI::Resources::EnvFile.new(api_key: @api_key, secret: @secret, extra: { "UUID" => @uuid })
        # @env_content = ShopifyCLI::Resources::EnvFile.read(@env)
        @script_project_repo = TestHelpers::FakeScriptProjectRepository.new
        @script_project_repo.create(
          language: "assemblyscript",
          extension_point_type: "discount",
          script_name: "script_name",
          env: @env
        )
        @script_project = @script_project_repo.get

        # @project = TestHelpers::FakeProject.new(directory: File.join(@context.root, @script_name), config: @config)
        # @project.env = @env

        @project = ShopifyCLI::Project.new(
          env: @env
        )

        Script::Loaders::Project.stubs(:load).with(directory: Dir.pwd,
          api_key: nil,
          api_secret: nil,
          uuid: nil).returns(@script_project)

        # Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(@script_project_repo)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call).with(@context, :script).returns(true)
      end

      def test_calls_push_script
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: @force, project: @script_project)
        @context.stubs(:tty?).returns(true)
        @context
          .expects(:puts)
          .with(@context.message("script.push.script_pushed", api_key: @api_key))
        perform_command
      end

      def test_help
        ShopifyCLI::Context
          .expects(:message)
          .with("script.push.help", ShopifyCLI::TOOL_NAME)
        Script::Command::Push.help
      end

      # def test_push_propagates_error_when_connect_fails
      #   err_msg = "error message"
      #   Layers::Application::ConnectApp
      #     .expects(:call)
      #     .raises(StandardError.new(err_msg))

      #   e = assert_raises(StandardError) { perform_command }
      #   assert_equal err_msg, e.message
      # end

      # def test_does_not_force_push_if_user_env_already_existed
      #   @force = false
      #   @context.stubs(:tty?).returns(true)
      #   Layers::Application::PushScript.expects(:call).with(ctx: @context, force: false, project: @script_project)
      #   perform_command
      # end

      # def test_force_pushes_script_if_user_env_was_just_created
      #   @force = false
      #   @context.stubs(:tty?).returns(true)
      #   Layers::Application::PushScript.expects(:call).with(ctx: @context, force: true, project: @script_project)
      #   perform_command
      # end

      def test_push_fails_when_no_api_key
        @context.stubs(:tty?).returns(true)
        Script::Loaders::Project.expects(:load)
          .raises(Layers::Infrastructure::Errors::ScriptEnvAppNotConnectedError.new)
        UI::ErrorHandler.expects(:pretty_print_and_raise).with do |_error, args|
          assert_equal args[:failed_op], @context.message("script.push.error.operation_failed_no_api_key")
        end
        perform_command
      end

      def test_push_missing_flags_on_ci
        Script::Loaders::Project.expects(:load)
          .raises(Layers::Infrastructure::Errors::ScriptEnvAppNotConnectedError.new)
        UI::ErrorHandler.expects(:pretty_print_and_raise).with do |_error, args|
          assert_equal args[:failed_op], @context.message("script.push.error.operation_failed_no_api_key")
        end
        @context.stubs(:tty?).returns(false)
        perform_command_with_flags
      end

      def test_push_missing_uuid_on_ci
        new_project = @script_project
        new_project.env[:extra]["UUID"] = nil
        @uuid = nil
        @context.stubs(:tty?).returns(false)
        Script::Loaders::Project.expects(:load).with(directory: Dir.pwd,
          api_key: @api_key,
          api_secret: @secret,
          uuid: "").returns(new_project)
        @context.expects(:puts).with(@context.message("script.push.error.operation_failed_no_uuid"))
        perform_command_with_flags
      end

      def test_push_on_ci
        @context.stubs(:tty?).returns(false)
        Script::Loaders::Project.expects(:load).with(directory: Dir.pwd,
          api_key: @api_key,
          api_secret: @secret,
          uuid: @uuid).returns(@script_project)
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: true, project: @script_project)
        perform_command_with_flags
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
