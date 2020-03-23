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

    register :Authenticate, 'authenticate', 'shopify-cli/commands/authenticate'
    register :Connect, 'connect', 'shopify-cli/commands/connect'
    register :Create, 'create', 'shopify-cli/commands/create'
    register :Deploy, 'deploy', 'shopify-cli/commands/deploy'
    register :Help, 'help', 'shopify-cli/commands/help'
    register :LoadDev, 'load-dev', 'shopify-cli/commands/load_dev'
    register :LoadSystem, 'load-system', 'shopify-cli/commands/load_system'
    register :Populate, 'populate', 'shopify-cli/commands/populate'
    register :Tunnel, 'tunnel', 'shopify-cli/commands/tunnel'
    register :Update, 'update', 'shopify-cli/commands/update'
  end
end
