# frozen_string_literal: true
require "shopify-cli/theme/dev_server"

module Theme
  module Commands
    class Serve < ShopifyCli::Command
      options do |parser, flags|
        # TODO: add env support. Now defaults to 'development'.
        # parser.on("--env=ENV") { |env| flags[:env] = env }
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
        parser.on("--debug") { flags[:debug] = true }
      end

      def call(*)
        flags = options.flags.dup
        ShopifyCli::Theme::DevServer.debug = true if flags.delete(:debug)

        CLI::UI::Frame.open(@ctx.message("theme.serve.serve")) do
          ShopifyCli::Theme::DevServer.start(@ctx, ".", **flags)
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.serve.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
