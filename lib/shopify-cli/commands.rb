require 'shopify_cli'

module ShopifyCli
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil,
    )

    def self.register(const, cmd, path = nil)
      autoload(const, path) if path
      Registry.add(->() { const_get(const) }, cmd)
    end

    def self.load_all_commands
      # commands available in all contexts
      register :Authenticate, 'authenticate', 'shopify-cli/commands/authenticate'
      register :Help, 'help', 'shopify-cli/commands/help'
      register :LoadDev, 'load-dev', 'shopify-cli/commands/load_dev'
      register :LoadSystem, 'load-system', 'shopify-cli/commands/load_system'
      register :Update, 'update', 'shopify-cli/commands/update'

      # commands available only at top-level folder context
      register :Create, 'create', 'shopify-cli/commands/create'

      # commands availalbe only in project context
      register :Deploy, 'deploy', 'shopify-cli/commands/deploy'

      # commands available in app project context
      register :Serve, 'serve', 'shopify-cli/commands/serve'
      register :Generate, 'generate', 'shopify-cli/commands/generate'
      register :Open, 'open', 'shopify-cli/commands/open'
      register :Tunnel, 'tunnel', 'shopify-cli/commands/tunnel'
      register :Populate, 'populate', 'shopify-cli/commands/populate'

      # commands available in script project context
      register :Test, 'test', 'shopify-cli/commands/test'
    end

    load_all_commands
  end
end
