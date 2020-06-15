# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class PushTest < MiniTest::Test
      def setup
        @context = TestHelpers::FakeContext.new
        @language = 'ts'
        @script_name = 'name'
        @ep_type = 'discount'
        @script_project = TestHelpers::FakeScriptProject.new(
          language: @language,
          extension_point_type: @ep_type,
          script_name: @script_name
        )
        @api_key = 'key'
        @force = true
        ScriptProject.stubs(:current).returns(@script_project)
        ShopifyCli::ProjectType.load_type(:script)
      end

      def test_calls_push_script
        Layers::Application::PushScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          language: @language,
          script_name: @script_name,
          extension_point_type: @ep_type,
          force: @force
        )

        @context
          .expects(:puts)
          .with(@context.message('script.push.script_pushed', api_key: @api_key))
        perform_command
      end

      def test_returns_help_if_language_is_not_supported
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

      def test_extended_help
        ShopifyCli::Context
          .expects(:message)
          .with('script.push.extended_help', ShopifyCli::TOOL_NAME)
        Script::Commands::Push.extended_help
      end

      private

      def perform_command
        run_cmd("push --api_key=#{@api_key} --force")
      end
    end
  end
end
