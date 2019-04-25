require 'shopify_cli'

module ShopifyCli
  module Commands
    class Generate < ShopifyCli::Command
      autoload :Page, 'shopify-cli/commands/generate/page'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'page'
          Page.call(@ctx, args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Bootstrap an app.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create <appname>}}
        HELP
      end
    end
  end
end
