# frozen_string_literal: true
require "shopify-cli/theme/dev_server"

module Theme
  class Command
    class Serve < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--env=ENV") { |env| flags[:env] = env }
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
      end

      def call(*)
        flags = options.flags.dup

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
