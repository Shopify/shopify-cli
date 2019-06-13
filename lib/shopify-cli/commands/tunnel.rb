# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Tunnel < ShopifyCli::Command
      # subcommands :start, :stop

      def call(args, _name)
        subcommand = args.shift
        task = ShopifyCli::Tasks::Tunnel.new
        case subcommand
        when 'start'
          task.call(@ctx)
        when 'stop'
          task.stop(@ctx)
        else
          puts CLI::UI.fmt(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Start or stop an http tunnel to your local development app using ngrok.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel [ start | stop ]}}
        HELP
      end
    end
  end
end
