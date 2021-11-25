# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @api_key = "apikey"
        @uuid = "uuid"
        @force = true
        @secret = "shh"
        @env = ShopifyCLI::Resources::EnvFile.new(api_key: @api_key, secret: @secret, extra: { "UUID" => @uuid })
        @script_project_repo = TestHelpers::FakeScriptProjectRepository.new
        @script_project_repo.create(
          language: "assemblyscript",
          extension_point_type: "discount",
          script_name: "script_name",
          env: @env
        )

        Layers::Application::ConnectApp.stubs(:call).returns(false)

        Script::Layers::Infrastructure::ScriptProjectRepository.stubs(:new).returns(@script_project_repo)
        ShopifyCLI::Tasks::EnsureProjectType.stubs(:call).with(@context, :script).returns(true)
      end

      def test_calls_push_script
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: @force)

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

      def test_push_propagates_error_when_connect_fails
        err_msg = "error message"
        Layers::Application::ConnectApp
          .expects(:call)
          .raises(StandardError.new(err_msg))

        e = assert_raises(StandardError) { perform_command }
        assert_equal err_msg, e.message
      end

      def test_does_not_force_push_if_user_env_already_existed
        @force = false
        Layers::Application::ConnectApp.expects(:call).returns(false)
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: false)
        perform_command
      end

      def test_force_pushes_script_if_user_env_was_just_created
        @force = false
        Layers::Application::ConnectApp.expects(:call).returns(true)
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: true)
        perform_command
      end

      def test_push_doesnt_print_api_key_when_it_hasnt_been_selected
        @script_project_repo.expects(:get).returns(nil)

        UI::ErrorHandler.expects(:pretty_print_and_raise).with do |_error, args|
          assert_equal args[:failed_op], @context.message("script.push.error.operation_failed_no_api_key")
        end

        perform_command
      end

      def test_push_prints_api_key_when_it_has_been_selected
        Layers::Application::PushScript.expects(:call).raises(StandardError.new)

        UI::ErrorHandler.expects(:pretty_print_and_raise).with do |_error, args|
          assert_equal args[:failed_op], @context.message(
            "script.push.error.operation_failed_with_api_key", api_key: @api_key
          )
        end

        perform_command
      end

      private

      def perform_command
        capture_io { run_cmd("script push #{@force ? "--force" : ""}") }
      end
    end
  end
end
