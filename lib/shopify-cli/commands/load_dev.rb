require 'shopify_cli'

module ShopifyCli
  module Commands
    class LoadDev < ShopifyCli::Command
      def call(args, _name)
        project_dir = File.expand_path(args.shift || Dir.pwd)
        ShopifyCli::Finalize.reload_shopify_from(project_dir)
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
