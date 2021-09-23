# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Tunnel < ExtensionCommand
      prerequisite_task ensure_project_type: :extension

      options do |parser, flags|
        parser.on("--port=PORT") { |port| flags[:port] = port }
      end

      AUTH_SUBCOMMAND = "auth"
      START_SUBCOMMAND = "start"
      STOP_SUBCOMMAND = "stop"
      STATUS_SUBCOMMAND = "status"
      DEFAULT_PORT = 39351

      def call(args, _name)
        subcommand = args.shift

        case subcommand
        when AUTH_SUBCOMMAND then authorize(args)
        when START_SUBCOMMAND then ShopifyCLI::Tunnel.start(@ctx, port: port)
        when STOP_SUBCOMMAND then ShopifyCLI::Tunnel.stop(@ctx)
        when STATUS_SUBCOMMAND then status
        else @ctx.puts(self.class.help)
        end
      end

      def self.help
        ShopifyCLI::Context.message("tunnel.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("tunnel.extended_help", ShopifyCLI::TOOL_NAME, DEFAULT_PORT)
      end

      private

      def status
        tunnel_urls = ShopifyCLI::Tunnel.urls
        tunnel_url = tunnel_urls.find { |url| url.start_with?("https://") }
        tunnel_url = tunnel_urls.first if tunnel_url.nil?

        if tunnel_url.nil?
          @ctx.puts(@ctx.message("tunnel.no_tunnel_running"))
        else
          @ctx.puts(@ctx.message("tunnel.tunnel_running_at", tunnel_url))
        end
      end

      def port
        return DEFAULT_PORT unless options.flags.key?(:port)

        port = options.flags[:port].to_i
        @ctx.abort(@ctx.message("tunnel.invalid_port", options.flags[:port])) unless port > 0
        port
      end

      def authorize(args)
        token = args.shift

        if token.nil?
          @ctx.puts(@ctx.message("tunnel.missing_token"))
          @ctx.puts("#{self.class.help}\n#{self.class.extended_help}")
        else
          ShopifyCLI::Tunnel.auth(@ctx, token)
        end
      end
    end
  end
end
