# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Tunnel < ShopifyCli::Command
      # subcommands :start, :stop

      def call(_args, _name)
        puts CLI::UI.fmt(self.class.help)
      end

      def self.help
        <<~HELP
          Start and manage an http tunnel.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} tunnel start|stop}}
        HELP
      end
    end
  end
end
