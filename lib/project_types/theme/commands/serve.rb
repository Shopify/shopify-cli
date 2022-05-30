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
        parser.on("-t", "--theme=NAME_OR_ID") { |theme| flags[:theme] = theme }
      end

      def call(_args, name)
        valid_authentication_method!

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

      private

      def valid_authentication_method!
        if exchange_token && !storefront_renderer_token
          ShopifyCLI::Context.abort(error_message, help_message)
        end
      end

      def error_message
        ShopifyCLI::Context.message("theme.serve.auth.error_message", ShopifyCLI::TOOL_NAME)
      end

      def help_message
        ShopifyCLI::Context.message("theme.serve.auth.help_message", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
      end

      def exchange_token
        ShopifyCLI::DB.get(:shopify_exchange_token)
      end

      def storefront_renderer_token
        ShopifyCLI::DB.get(:storefront_renderer_production_exchange_token)
      end
    end
  end
end
