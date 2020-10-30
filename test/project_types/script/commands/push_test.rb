# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        super
        @context = TestHelpers::FakeContext.new
        @language = 'ts'
        @script_name = 'name'
        @ep_type = 'discount'
        @script_project = TestHelpers::FakeScriptProject.new(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name
        )
        @api_key = 'apikey'
        @source_file = 'src/script.ts'
        @force = true
        ScriptProject.stubs(:current).returns(@script_project)
        @script_project.stubs(:env).returns({ api_key: @api_key })
        ShopifyCli::ProjectType.load_type(:script)
      end

      def test_calls_push_script
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])
        Layers::Application::PushScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          language: @language,
          script_name: @script_name,
          source_file: @source_file,
          extension_point_type: @ep_type,
          force: @force
        )

        @context
          .expects(:puts)
          .with(@context.message('script.push.script_pushed', api_key: @api_key))
        perform_command
      end

      def test_returns_help_if_language_is_not_supported
        ShopifyCli::Tasks::EnsureEnv
          .any_instance.expects(:call)
          .with(@context, required: [:api_key, :secret, :shop])
        @script_project.stubs(:language).returns('invalid')
        @context.expects(:puts).with(Push.help)
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
