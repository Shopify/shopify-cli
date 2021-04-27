# frozen_string_literal: true

require "project_types/script/test_helper"

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @api_key = "apikey"
        @force = true
        @env = stub(api_key: @api_key)
        @script_project = TestHelpers::FakeScriptProject.new(
          language: "assemblyscript",
          extension_point_type: "discount",
          script_name: "script_name",
          env: @env
        )
        Script::Layers::Infrastructure::ScriptProjectRepository.any_instance.stubs(:get).returns(@script_project)
        ShopifyCli::ProjectType.load_type(:script)
      end

      def test_calls_push_script
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])

        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: @force)

        @context
          .expects(:puts)
          .with(@context.message("script.push.script_pushed", api_key: @api_key))
        perform_command
      end

      def test_help
        ShopifyCli::Context
          .expects(:message)
          .with("script.push.help", ShopifyCli::TOOL_NAME)
        Script::Commands::Push.help
      end

      def test_push_propagates_error_when_ensure_env_fails
        @env = nil

        err_msg = "error message"
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])
          .raises(StandardError.new(err_msg))

        e = assert_raises(StandardError) { perform_command }
        assert_equal err_msg, e.message
      end

      private

      def perform_command
        capture_io { run_cmd("push --force") }
      end
    end
  end
end
