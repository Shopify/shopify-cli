# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ShopifyCli::Command

      YARN_SERVE_COMMAND = %w(yarn server)
      NPM_SERVE_COMMAND = %w(npm run-script server)

      def call(args, command_name)
        CLI::UI::Frame.open(Content::Serve::FRAME_TITLE) do
          @ctx.abort(Content::Serve::SERVE_FAILURE_MESSAGE) unless serve.success?
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
