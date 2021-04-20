# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand
      def call(_args, _command_name)
        specification_handler.serve(@ctx)
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
