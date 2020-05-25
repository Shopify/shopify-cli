require 'shopify_cli'

module ShopifyCli
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: 'help',
      contextual_resolver: nil,
    )
    @core_commands = []

    def self.register(const, cmd, path = nil, is_core = false)
      autoload(const, path) if path
      Registry.add(->() { const_get(const) }, cmd)
      @core_commands.push(cmd) if is_core
    end

    def self.core_command?(cmd)
      @core_commands.include?(cmd)
    end

    register :Connect, 'connect', 'shopify-cli/commands/connect', true
    register :Create, 'create', 'shopify-cli/commands/create', true
    register :Help, 'help', 'shopify-cli/commands/help', true
    register :Logout, 'logout', 'shopify-cli/commands/logout', true
    register :System, 'system', 'shopify-cli/commands/system', true
    register :Update, 'update', 'shopify-cli/commands/update', true
    register :Version, 'version', 'shopify-cli/commands/version', true
  end
end
