require 'cli/kit'

module ShopifyCli
  class HelpResolver < CLI::Kit::Resolver
    def call(args)
      args = args.dup
      return super(args) unless args.first
      if args.first.include?('-h') || args.first.include?('--help')
        help = Commands::Help
        help.ctx = Context.new
        help.call([], nil)
        raise ShopifyCli::AbortSilent
      else
        super(args)
      end
    end

    def commands_and_aliases
      command_names = @command_registry.command_names.filter{ |name| @command_registry.exist?(name) }
      command_names + @command_registry.aliases.keys
    end
  end
end
