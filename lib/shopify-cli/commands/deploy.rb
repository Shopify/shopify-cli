# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::ContextualCommand
      available_in :app

      autoload :Heroku, 'shopify-cli/commands/deploy/heroku'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'heroku'
          Heroku.call(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Deploy the current app project to a hosting service. Heroku ({{underline:https://www.heroku.com}}) is currently the only option, but more will be added in the future.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy [heroku]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          Subcommands:

          * heroku: Deploys the current app project to Heroku. Usage:

              {{command:#{ShopifyCli::TOOL_NAME} deploy heroku}}
        HELP
      end
    end
  end
end
