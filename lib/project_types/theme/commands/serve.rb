# frozen_string_literal: true
require "shopify-cli/theme/dev_server"

module Theme
  class Command
    class Serve < ShopifyCli::SubCommand
      options do |parser, flags|
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
        parser.on("--path=PATH") { |path| flags[:working_dir] = path.to_s }
      end

      def call(*)
        flags = options.flags.dup
        ShopifyCli::Theme::DevServer.start(@ctx, **flags) do |syncer|
          UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delay_low_priority_files: true)
        end
      end

      def self.help
        ShopifyCli::Context.message("theme.serve.help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
