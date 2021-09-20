# frozen_string_literal: true

require "shopify_cli"

module Rails
  class Command
    class Tunnel < ShopifyCLI::SubCommand
      # subcommands :auth, :start, :stop

      prerequisite_task ensure_project_type: :rails

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when "auth"
          token = args.shift
          if token.nil?
            @ctx.puts(@ctx.message("rails.tunnel.error.token_argument_missing"))
            @ctx.puts("#{self.class.help}\n#{self.class.extended_help}")
          else
            ShopifyCLI::Tunnel.auth(@ctx, token)
          end
        when "start"
          ShopifyCLI::Tunnel.start(@ctx)
        when "stop"
          ShopifyCLI::Tunnel.stop(@ctx)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        ShopifyCLI::Context.message("rails.tunnel.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("rails.tunnel.extended_help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
