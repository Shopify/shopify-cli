# frozen_string_literal: true

require "shopify_cli"

module PHP
  module Commands
    class Tunnel < ShopifyCli::Command
      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when "auth"
          token = args.shift
          if token.nil?
            @ctx.puts(@ctx.message("php.tunnel.error.token_argument_missing"))
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
        ShopifyCli::Context.message("php.tunnel.help", ShopifyCli::TOOL_NAME)
      end

      def self.extended_help
        ShopifyCli::Context.message("php.tunnel.extended_help", ShopifyCli::TOOL_NAME)
      end
    end
  end
end
