# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class DeployTest < MiniTest::Test
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

      def test_calls_deploy_script
        Layers::Application::DeployScript.expects(:call).with(
          ctx: @context,
          api_key: @api_key,
          language: @language,
          script_name: @script_name,
          extension_point_type: @ep_type,
          force: @force
        )

        @context
          .expects(:puts)
          .with(format(Deploy::OPERATION_SUCCESS_MESSAGE, api_key: @api_key))
        perform_command
      end

      def test_returns_help_if_language_is_not_supported
        @script_project.stubs(:language).returns('invalid')
        @context.expects(:puts).with(Deploy.help)
        perform_command
      end

      private

      def perform_command
        run_cmd("deploy --api_key=#{@api_key} --force")
      end
    end
  end
end
