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

    # commands available in all contexts
    register :Authenticate, 'authenticate', 'shopify-cli/commands/authenticate'
    register :Help, 'help', 'shopify-cli/commands/help'
    register :LoadDev, 'load-dev', 'shopify-cli/commands/load_dev'
    register :LoadSystem, 'load-system', 'shopify-cli/commands/load_system'
    register :Update, 'update', 'shopify-cli/commands/update'

    if Project.is_at_top_level?
      # commands available only at root folder context
      register :Create, 'create', 'shopify-cli/commands/create'
    else
      # commands availalbe only in project context
      register :Deploy, 'deploy', 'shopify-cli/commands/deploy'
      register :Populate, 'populate', 'shopify-cli/commands/populate'
      register :Serve, 'serve', 'shopify-cli/commands/serve'
      register :Connect, 'connect', 'shopify-cli/commands/connect'
      register :Generate, 'generate', 'shopify-cli/commands/generate'
      register :Open, 'open', 'shopify-cli/commands/open'
      register :Test, 'test', 'shopify-cli/commands/test'
      register :Tunnel, 'tunnel', 'shopify-cli/commands/tunnel'
    end
  end
end
