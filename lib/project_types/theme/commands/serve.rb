# frozen_string_literal: true
require "shopify-cli/theme/dev_server"

module Theme
  module Commands
    class Serve < ShopifyCli::Command
      options do |parser, flags|
        # TODO: add env support. Now defaults to 'development'.
        # parser.on("--env=ENV") { |env| flags[:env] = env }
        parser.on("--port") { |port| flags[:port] = port.to_i }
      end

      def call(*)
        CLI::UI::Frame.open(@ctx.message("theme.serve.serve")) do
          ShopifyCli::Theme::DevServer.start(".", **options.flags)
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.serve.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
