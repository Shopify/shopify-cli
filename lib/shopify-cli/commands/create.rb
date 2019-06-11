require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::Command
      autoload :Project, 'shopify-cli/commands/create/project'

      def call(args, _name)
        subcommand = args.shift
        case subcommand
        when 'project'
          Project.new(@ctx).call(args)
        else
          @ctx.puts(self.class.help)
        end
      end

      def self.help
        <<~HELP
          Create.
          Usage: {{command:#{ShopifyCli::TOOL_NAME} create project|}}
        HELP
      end

      def self.extended_help
        <<~HELP
          Subcommands:

          * project: Creates an app based on type selected. Usage:

              {{command:#{ShopifyCli::TOOL_NAME} create project <appname>}}
        HELP
      end
    end
  end
end
