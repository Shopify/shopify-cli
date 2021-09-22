# frozen_string_literal: true

require "shopify_cli"

module PHP
  class Command
    class Tunnel < ShopifyCLI::SubCommand
      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when "auth"
          token = args.shift
          if token.nil?
            @ctx.puts(@ctx.message("php.tunnel.error.token_argument_missing"))
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
        ShopifyCLI::Context.message("php.tunnel.help", ShopifyCLI::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCLI::Context.message("php.tunnel.extended_help", ShopifyCLI::TOOL_NAME)
      end
    end
  end
end
