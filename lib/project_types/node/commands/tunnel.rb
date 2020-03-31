# frozen_string_literal: true

require 'shopify_cli'

module Node
  module Commands
    class Tunnel < ShopifyCli::Command
      # subcommands :auth, :start, :stop

      def call(args, _name)
        subcommand = args.shift
        task = ShopifyCli::Tasks::Tunnel.new
        case subcommand
        when 'auth'
          token = args.shift
          task.auth(@ctx, token)
        when 'start'
          task.call(@ctx)
        when 'stop'
          task.stop(@ctx)
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

            {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to allow connecting with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
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
