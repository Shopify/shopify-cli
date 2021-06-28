require "shopify_cli"

module ShopifyCli
  module Commands
    Registry = CLI::Kit::CommandRegistry.new(
      default: "help",
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

    register :Config, "config", "shopify-cli/commands/config", true
    register :Help, "help", "shopify-cli/commands/help", true
    register :Login, "login", "shopify-cli/commands/login", true
    register :Logout, "logout", "shopify-cli/commands/logout", true
    register :Populate, "populate", "shopify-cli/commands/populate", true
    register :Store, "store", "shopify-cli/commands/store", true
    register :Switch, "switch", "shopify-cli/commands/switch", true
    register :System, "system", "shopify-cli/commands/system", true
    register :Version, "version", "shopify-cli/commands/version", true
    register :Whoami, "whoami", "shopify-cli/commands/whoami", true

    autoload :Connect, "shopify-cli/commands/connect"
  end
end
