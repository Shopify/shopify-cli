require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadDev < ShopifyCli::Command
      hidden_command

      def call(args, _name)
        project_dir = File.expand_path(args.shift || Dir.pwd)
        unless File.exist?(project_dir)
          raise(ShopifyCli::AbortSilent, "{{x}} #{project_dir} does not exist")
        end
        @ctx.done("Reloading #{TOOL_FULL_NAME} from #{project_dir}")
        ShopifyCli::Core::Finalize.reload_shopify_from(project_dir)
      end

      def self.help
        <<~HELP
          Load a development instance of Shopify App CLI from the given path. This command is intended for development work on the CLI itself.
            Usage: {{command:#{ShopifyCli::TOOL_NAME} load-dev `/absolute/path/to/cli/instance`}}
        HELP
      end
    end
  end
end
