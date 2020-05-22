# frozen_string_literal: true
require 'shopify_cli'

module Extension
  module Commands
    class Tunnel < ShopifyCli::Command
      options do |parser, flags|
        parser.on('--port=PORT') { |port| flags[:port] = port }
      end

      AUTH_SUBCOMMAND = 'auth'
      START_SUBCOMMAND = 'start'
      STOP_SUBCOMMAND = 'stop'
      DEFAULT_PORT = 39351

      def call(args, _name)
        subcommand = args.shift

        case subcommand
        when AUTH_SUBCOMMAND then authorize(args)
        when START_SUBCOMMAND then ShopifyCli::Tunnel.start(@ctx, port: port)
        when STOP_SUBCOMMAND then ShopifyCli::Tunnel.stop(@ctx)
        else @ctx.puts(self.class.help)
        end
      end

      private

      def self.help
        <<~HELP
          Start or stop an http tunnel to your local development extension using ngrok.
            Usage: {{command:%s tunnel [ auth | start | stop ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}

            {{cyan:auth}}: Writes an ngrok auth token to ~/.ngrok2/ngrok.yml to connect with an ngrok account. Visit https://dashboard.ngrok.com/signup to sign up.
              Usage: {{command:%1$s tunnel auth <token>}}

            {{cyan:start}}: Starts an ngrok tunnel, will print the URL for an existing tunnel if already running.
              Usage: {{command:%1$s tunnel start}}

            {{cyan:stop}}: Stops the ngrok tunnel.
              Usage: {{command:%1$s tunnel stop}}
        HELP
      end

      def port
        return DEFAULT_PORT unless options.flags.key?(:port)

        port = options.flags[:port].to_i
        @ctx.abort(Content::Tunnel::INVALID_PORT % options.flags[:port]) unless port > 0
        port
      end

      def authorize(args)
        token = args.shift

        if token.nil?
          @ctx.puts(Content::Tunnel::MISSING_TOKEN)
          @ctx.puts("#{self.class.help}\n#{self.class.extended_help}")
        else
          ShopifyCli::Tunnel.auth(@ctx, token)
        end
      end
    end
  end
end
