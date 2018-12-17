require 'shopify-cli'

module ShopifyCli
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil
    )

    def self.register(const, cmd, path)
      autoload(const, path)
      Registry.add(->() { const_get(const) }, cmd)
    end

    register :Create, 'create', 'shopify-cli/commands/create'
    register :Server, 'server', 'shopify-cli/commands/server'
    register :Help, 'help', 'shopify-cli/commands/help'
  end
end
