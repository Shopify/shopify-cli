# frozen_string_literal: true
require "shopify_cli/theme/dev_server"
require "project_types/theme/commands/common/root_helper"

module Theme
  class Command
    class Serve < ShopifyCLI::Command::SubCommand
      include Common::RootHelper

      recommend_default_ruby_range

      DEFAULT_HTTP_HOST = "127.0.0.1"

      options do |parser, flags|
        parser.on("--host=HOST") { |host| flags[:host] = host.to_s }
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
        parser.on("--poll") { flags[:poll] = true }
        parser.on("--live-reload=MODE") { |mode| flags[:mode] = as_reload_mode(mode) }
        parser.on("--theme-editor-sync") { flags[:editor_sync] = true }
      end

      def call(_args, name)
        root = root_value(options, name)
        flags = options.flags.dup
        host = flags[:host] || DEFAULT_HTTP_HOST
        ShopifyCLI::Theme::DevServer.start(@ctx, root, host: host, **flags) do |syncer|
          UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delay_low_priority_files: true)
        end
      rescue ShopifyCLI::Theme::DevServer::AddressBindingError
        raise ShopifyCLI::Abort,
          ShopifyCLI::Context.message("theme.serve.error.address_binding_error", ShopifyCLI::TOOL_NAME)
      end

      def self.as_reload_mode(mode)
        ShopifyCLI::Theme::DevServer::ReloadMode.get!(mode)
      end

      def self.help
        ShopifyCLI::Context.message("theme.serve.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
