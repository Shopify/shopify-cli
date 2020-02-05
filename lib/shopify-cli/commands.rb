require 'shopify_cli'

module ShopifyCli
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil,
    )

    class << self
      def register(const, cmd, path = nil)
        autoload(const, path) if path
        Registry.add(->() { const_get(const) }, cmd)
      end

      def load_commands_for_all_contexts
        register :Authenticate, 'authenticate', 'shopify-cli/commands/authenticate'
        register :Help, 'help', 'shopify-cli/commands/help'
        register :LoadDev, 'load-dev', 'shopify-cli/commands/load_dev'
        register :LoadSystem, 'load-system', 'shopify-cli/commands/load_system'
        register :Update, 'update', 'shopify-cli/commands/update'
      end

      def load_commands_for_top_level
        register :Create, 'create', 'shopify-cli/commands/create'
      end

      def load_commands_for_all_projects
        register :Deploy, 'deploy', 'shopify-cli/commands/deploy'
        register :Connect, 'connect', 'shopify-cli/commands/connect'
      end

      def load_commands_for_app_project
        register :Serve, 'serve', 'shopify-cli/commands/serve'
        register :Generate, 'generate', 'shopify-cli/commands/generate'
        register :Open, 'open', 'shopify-cli/commands/open'
        register :Tunnel, 'tunnel', 'shopify-cli/commands/tunnel'
        register :Populate, 'populate', 'shopify-cli/commands/populate'
      end

      def load_commands_for_script_project
        register :Test, 'test', 'shopify-cli/commands/test'
      end

      def load_all_commands
        load_commands_for_all_contexts
        load_commands_for_top_level
        load_commands_for_all_projects
        load_commands_for_app_project
        load_commands_for_script_project
      end
    end

    load_all_commands
  end
end
