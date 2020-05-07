# frozen_string_literal: true

module Script
  module Commands
    class Test < ShopifyCli::Command
      OPERATION_FAILED_MESSAGE = "Tests didn't run or they ran with failures."
      OPERATION_SUCCESS_MESSAGE = "{{v}} Tests finished."

      def call(_args, _name)
        project = Script::ScriptProject.current
        Layers::Application::TestScript.call(
          ctx: @ctx,
          language: project.language,
          extension_point_type: project.extension_point_type,
          script_name: project.script_name
        )
        @ctx.puts(OPERATION_SUCCESS_MESSAGE)
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: OPERATION_FAILED_MESSAGE)
      end

      def self.help
        <<~HELP
        Runs unit tests on your script.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} test}}
        HELP
      end
    end
  end
end
