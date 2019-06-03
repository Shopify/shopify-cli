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

    register :Create, 'create', 'shopify-cli/commands/create'
    register :Generate, 'generate', 'shopify-cli/commands/generate'
    register :Help, 'help', 'shopify-cli/commands/help'
    register :LoadDev, 'load-dev', 'shopify-cli/commands/load_dev'
    register :LoadSystem, 'load-system', 'shopify-cli/commands/load_system'
    register :Serve, 'serve', 'shopify-cli/commands/serve'
    register :Tunnel, 'tunnel', 'shopify-cli/commands/tunnel'
    register :Update, 'update', 'shopify-cli/commands/update'
    register :Populate, 'populate', 'shopify-cli/commands/populate'
  end
end
