# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand
      YARN_SERVE_COMMAND = %w(server)
      NPM_SERVE_COMMAND = %w(run-script server)

      def call(_args, _command_name)
        CLI::UI::Frame.open(@ctx.message('serve.frame_title')) do
          success = ShopifyCli::JsSystem.call(@ctx, yarn: YARN_SERVE_COMMAND, npm: NPM_SERVE_COMMAND)
          @ctx.abort(@ctx.message('serve.serve_failure_message')) unless success
        end
      end

      def self.help
        <<~HELP
          Serve your extension in a local simulator for development.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end
    end
  end
end
