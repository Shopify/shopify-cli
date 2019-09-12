# frozen_string_literal: true

require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy < ShopifyCli::Command
      autoload :Heroku, 'shopify-cli/commands/deploy/heroku'
      autoload :Now, 'shopify-cli/commands/deploy/now'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'heroku'
          Heroku.call(@ctx, args)
        when 'now'
          Now.call(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Deploy the current app project to a hosting platform.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy [ heroku | now ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}
            
            {{cyan:heroku}} Deploys the current app project to Heroku. 
              Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy heroku }}
            
            {{cyan:now}} Deploys the current app project to Zeit Now. 
              Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy now }}
              
        HELP
      end
    end
  end
end
