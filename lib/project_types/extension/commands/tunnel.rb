# frozen_string_literal: true
require "shopify_cli"

module Extension
  class Command
    class Tunnel < ExtensionCommand
      prerequisite_task ensure_project_type: :extension

      recommend_default_node_range

      options do |parser, flags|
        parser.on("--port=PORT") { |port| flags[:port] = port }
      end

      START_SUBCOMMAND = "start"
      STOP_SUBCOMMAND = "stop"
      STATUS_SUBCOMMAND = "status"
      DEFAULT_PORT = 39351

      def call(args, _name)
        subcommand = args.shift

        case subcommand
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
        tunnel_url = ShopifyCLI::Tunnel.url(@ctx)
        if tunnel_url
          @ctx.puts(@ctx.message("tunnel.tunnel_running_at", tunnel_url))
        else
          @ctx.puts(@ctx.message("tunnel.no_tunnel_running"))
        end
      end

      def port
        return DEFAULT_PORT unless options.flags.key?(:port)

        port = options.flags[:port].to_i
        @ctx.abort(@ctx.message("tunnel.invalid_port", options.flags[:port])) unless port > 0
        port
      end
    end
  end
end
