# frozen_string_literal: true
require 'shopify_cli'

module Rails
  module Commands
    class Generate < ShopifyCli::Command
      subcommand :Webhook, 'webhook', 'project_types/rails/commands/generate/webhook'

      def call(*)
        @ctx.puts(self.class.help)
      end

      def self.help
        <<~HELP
          Generate code in your app project. Currently supports generating new webhooks.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook}}
        HELP
      end

      def self.extended_help
        <<~HELP
          {{bold:Subcommands:}}
            {{cyan:webhook}}: Generate and register a new webhook that listens for the specified Shopify store event.
              Usage: {{command:#{ShopifyCli::TOOL_NAME} generate webhook [type]}}
          {{bold:Examples:}}
            {{cyan:shopify generate webhook PRODUCTS_CREATE}}
              Generate and register a new webhook that will be called every time a new product is created on your store.
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
