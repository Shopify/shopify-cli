# frozen_string_literal: true
require 'shopify_cli'

module Rails
  module Commands
    class Deploy < ShopifyCli::Command
      subcommand :Heroku, 'heroku', Project.project_filepath('commands/deploy/heroku')

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Deploy the current Rails project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy [heroku]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          Subcommands:
          * heroku: Deploys the current Rails project to Heroku.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy heroku}}
        HELP
      end
    end
  end
end
