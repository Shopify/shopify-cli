# frozen_string_literal: true
require 'shopify_cli'

module Node
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Page, 'page', 'project_types/node/commands/generate/page'
      subcommand :Billing, 'billing', 'project_types/node/commands/generate/billing'
      subcommand :Webhook, 'webhook', 'project_types/node/commands/generate/webhook'

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Generate code in your app project. Supports generating new pages, new billing API calls, or new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate [ page | billing | webhook ]}}
        HELP
      end

      def self.extended_help
        <<~HELP
          help
        HELP
      end

      def self.run_generate(script, name, ctx)
        stat = ctx.system(script)
        unless stat.success?
          raise(ShopifyCli::Abort, CLI::UI.fmt(response(stat.exitstatus, name)))
        end
      end

      def self.response(code, name)
        case code
        when 1
          "{{x}} Error generating #{name}"
        when 2
          "{{x}} #{name} already exists!"
        else
          '{{x}} Error'
        end
      end
    end
  end
end
