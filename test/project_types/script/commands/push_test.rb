# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @language = 'assemblyscript'
        @script_name = 'name'
        @ep_type = 'discount'
        @api_key = 'apikey'
        @script_project = TestHelpers::FakeScriptProject.new(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name,
          env: { api_key: @api_key }
        )
        @force = true
        ScriptProject.stubs(:current).returns(@script_project)
        ShopifyCli::ProjectType.load_type(:script)
      end

      def test_calls_push_script
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])
        Layers::Application::PushScript.expects(:call).with(ctx: @context, force: @force)

        @context
          .expects(:puts)
          .with(@context.message('script.push.script_pushed', api_key: @api_key))
        perform_command
      end

      def test_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.push.help', ShopifyCli::TOOL_NAME)
        Script::Commands::Push.help
      end

      private

      def perform_command
        run_cmd("push --force")
      end
    end
  end
end
