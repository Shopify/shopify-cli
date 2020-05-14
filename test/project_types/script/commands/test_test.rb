# frozen_string_literal: true

require 'project_types/script/test_helper'

module Script
  module Commands
    class TestTest < MiniTest::Test
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
        Script::ScriptProject.stubs(:current).returns(@script_project)
      end

      def test_calls_test_service
        Script::Layers::Application::TestScript
          .expects(:call)
          .with(ctx: @context, language: @language, script_name: @script_name, extension_point_type: @ep_type)

        @context
          .expects(:puts)
          .with(@context.message('script.test.success'))
        perform_command
      end

      private

      def perform_command
        run_cmd('test')
      end
    end
  end
end
