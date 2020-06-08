# frozen_string_literal: true

module Script
  module Commands
    class Test < ShopifyCli::Command
      def call(args, _name)
        return @ctx.puts(self.class.help) if args.include?('help')
        project = Script::ScriptProject.current
        Layers::Application::TestScript.call(
          ctx: @ctx,
          language: project.language,
          extension_point_type: project.extension_point_type,
          script_name: project.script_name
        )
        @ctx.puts(@ctx.message('script.test.success'))
      rescue StandardError => e
        UI::ErrorHandler.pretty_print_and_raise(e, failed_op: @ctx.message('script.test.error.operation_failed'))
      end

      def self.help
        ShopifyCli::Context.message('script.test.help', ShopifyCli::TOOL_NAME)
      end
    end
  end
end
