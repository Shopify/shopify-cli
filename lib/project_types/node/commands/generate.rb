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
        ShopifyCli::Context.message('node.generate.help')
      end

      def self.extended_help
        help
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          ctx.abort(response(stat.exitstatus, name, ctx))
        end
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
