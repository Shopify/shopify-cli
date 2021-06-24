# frozen_string_literal: true

require "shopify_cli"

module Rails
  class Command
    class Tunnel < ShopifyCli::SubCommand
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
            ShopifyCli::Tunnel.auth(@ctx, token)
          end
        when "start"
          ShopifyCli::Tunnel.start(@ctx)
        when "stop"
          ShopifyCli::Tunnel.stop(@ctx)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        ShopifyCli::Context.message("rails.tunnel.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("rails.tunnel.extended_help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
