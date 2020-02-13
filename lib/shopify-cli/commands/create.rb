require 'shopify_cli'

module ShopifyCli
  module Commands
    class Create < ShopifyCli::ContextualCommand
      subcommand :App, 'app', 'shopify-cli/commands/create/app'
      subcommand(:Script, 'script', 'shopify-cli/commands/create/script') if ENV['SCRIPTS_PLATFORM']
      available_in_contexts 'create', [:top_level]

      def call(args, *)
        return project_command_moved_warning if args.first == 'project'
        @ctx.puts(self.class.help)
      end

      private

      def project_command_moved_warning
        @ctx.puts(
          '{{yellow:The project command has been renamed app. Run the following command:}} {{cyan:shopify create app}}'
        )
      end
    end
  end
end
