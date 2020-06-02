# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand

      YARN_SERVE_COMMAND = %w(yarn server)
      NPM_SERVE_COMMAND = %w(npm run-script server)

      def call(args, command_name)
        CLI::UI::Frame.open(@ctx.message('serve.frame_title')) do
          @ctx.abort(@ctx.message('serve.serve_failure_message')) unless serve.success?
        end
      end

      def self.help
        <<~HELP
          Serve your extension in a local simulator for development.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
        HELP
      end

      private

      def yarn_available?
        @yarn_availability ||= JsDeps.new(ctx: @ctx).yarn?
      end

      def serve
        serve_command = yarn_available? ? YARN_SERVE_COMMAND : NPM_SERVE_COMMAND
        @ctx.system(*serve_command)
      end
    end
  end
end
