# frozen_string_literal: true

require 'shopify_cli'

module Rails
  module Commands
    class Tunnel < ShopifyCli::Command
      # subcommands :auth, :start, :stop

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'auth'
          token = args.shift
          if token.nil?
            @ctx.puts("{{x}} {{red:auth requires a token argument}}\n\n")
            @ctx.puts("#{self.class.help}\n#{self.class.extended_help}")
          else
            ShopifyCli::Tunnel.auth(@ctx, token)
          end
        when 'start'
          ShopifyCli::Tunnel.start(@ctx)
        when 'stop'
          ShopifyCli::Tunnel.stop(@ctx)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Start or stop an http tunnel to your local development app using ngrok.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel [ auth | start | stop ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel auth <token>}}

            {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel start}}

            {{cyan:stop}}: Stops the ngrok tunnel.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel stop}}

        HELP
      end
    end
  end
end
