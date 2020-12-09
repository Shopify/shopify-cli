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
        ShopifyCli::Context.message('node.generate.help', ShopifyCli::TOOL_NAME)
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
        extended_help += ShopifyCli::Context.message('node.generate.extended_help', ShopifyCli::TOOL_NAME)
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        ctx.abort(response(stat.exitstatus, name, ctx)) unless stat.success?
      end

      def self.response(code, name, ctx)
        case code
        when 1
          ctx.message('node.generate.error.generic', name)
        when 2
          ctx.message('node.generate.error.name_exists', name)
        else
          ctx.message('node.error.generic')
        end
      end
    end
  end
end
