# frozen_string_literal: true
require 'shopify_cli'

module Node
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Page, 'page', Project.project_filepath('commands/generate/page')
      subcommand :Billing, 'billing', Project.project_filepath('commands/generate/billing')
      subcommand :Webhook, 'webhook', Project.project_filepath('commands/generate/webhook')

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Generate code in your Node project. Supports generating new billing API calls, new pages, or new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ billing | page | webhook ]}}
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
