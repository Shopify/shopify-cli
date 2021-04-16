# frozen_string_literal: true

module Extension
  module Commands
    class Serve < ExtensionCommand
      options do |parser, flags|
        parser.on("--tunnel=TUNNEL") { |tunnel| flags[:tunnel] = tunnel }
      end

      def call(_args, _command_name)
        specification_handler.serve(@ctx, options.flags)
      end

      def self.help
        <<~HELP
          Serve your extension in a local simulator for development.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} serve}}
            Options:
            {{command:--tunnel=TUNNEL}} Establish a tunnel (default: false)
        HELP
      end
    end
  end
end
