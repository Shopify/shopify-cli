require "shopify_cli"

module ShopifyCLI
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

    register :Config, "config", "shopify_cli/commands/config", true
    register :Help, "help", "shopify_cli/commands/help", true
    register :Login, "login", "shopify_cli/commands/login", true
    register :Logout, "logout", "shopify_cli/commands/logout", true
    register :Populate, "populate", "shopify_cli/commands/populate", true
    register :Reporting, "reporting", "shopify_cli/commands/reporting", true
    register :Store, "store", "shopify_cli/commands/store", true
    register :Switch, "switch", "shopify_cli/commands/switch", true
    register :System, "system", "shopify_cli/commands/system", true
    register :Version, "version", "shopify_cli/commands/version", true
    register :Whoami, "whoami", "shopify_cli/commands/whoami", true
    register :App, "app", "shopify_cli/commands/app", true

    autoload :Connect, "shopify_cli/commands/connect"
  end
end
