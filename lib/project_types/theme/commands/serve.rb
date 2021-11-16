# frozen_string_literal: true
require "shopify_cli/theme/dev_server"

module Theme
  class Command
    class Serve < ShopifyCLI::Command::SubCommand
      DEFAULT_HTTP_HOST = "127.0.0.1"

      options do |parser, flags|
        parser.on("--host=HOST") { |host| flags[:host] = host.to_s }
        parser.on("--port=PORT") { |port| flags[:port] = port.to_i }
        parser.on("--poll") { flags[:poll] = true }
        parser.on("-f", "--force") { flags[:force] = true }
      end

      def call(*)
        flags = options.flags.dup
        flags[:http_bind] = flags.delete(:host) || DEFAULT_HTTP_HOST
        flags[:confirm] = !flags.delete(:force)
        ShopifyCLI::Theme::DevServer.start(@ctx, ".", **flags) do |syncer|
          UI::SyncProgressBar.new(syncer).progress(:upload_theme!, delay_low_priority_files: true)
        end
      rescue ShopifyCLI::Theme::DevServer::AddressBindingError
        raise ShopifyCLI::Abort,
          ShopifyCLI::Context.message("theme.serve.error.address_binding_error", ShopifyCLI::TOOL_NAME)
      end

      def self.help
        ShopifyCLI::Context.message("theme.serve.help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
