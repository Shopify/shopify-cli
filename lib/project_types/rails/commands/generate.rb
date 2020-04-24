# frozen_string_literal: true
require 'shopify_cli'

module Rails
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Webhook, 'webhook', Project.project_filepath('commands/generate/webhook')

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Generate code in your Rails project. Currently supports generating new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ webhook ]}}
        HELP
      end

      def self.extended_help
        extended_help = "{{bold:Subcommands:}}\n"
        subcommand_registry.resolved_commands.sort.each do |name, klass|
          extended_help += "  {{cyan:#{name}}}: "

          if (subcmd_help = klass.help)
            extended_help += subcmd_help.gsub("\n  ", "\n    ")
          end
          extended_help += "\n"
        end
        extended_help += <<~EXAMPLES
          {{bold:Examples:}}
            {{cyan:#{ShopifyCli::TOOL_NAME} generate webhook PRODUCTS_CREATE}}
              Generate and register a new webhook that will be called every time a new product is created on your store.
        EXAMPLES
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          ctx.abort(response(stat.exitstatus, name))
        end
      end

      def self.response(code, name)
        case code
        when 1
          "Error generating #{name}"
        when 2
          "#{name} already exists!"
        else
          'Error'
        end
      end
    end
  end
end
