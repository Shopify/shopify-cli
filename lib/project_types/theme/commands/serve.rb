# frozen_string_literal: true
require "shopify_cli/theme/dev_server"

module Theme
  class Command
    class Serve < ShopifyCLI::SubCommand
      options do |parser, flags|
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
        parser.on("--poll") { flags[:poll] = true }
      end

      def call(*)
        flags = options.flags.dup
        ShopifyCLI::Theme::DevServer.start(@ctx, ".", **flags) do |syncer|
          UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delay_low_priority_files: true)
        end
      end

      def self.help
        ShopifyCLI::Context.message("theme.serve.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
