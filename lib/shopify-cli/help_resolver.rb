require 'cli/kit'

module ShopifyCli
  class HelpResolver < CLI::Kit::Resolver
    def call(args)
      args = args.dup
      if args.first.include?('-h') || args.first.include?('--help')
        help = Commands::Help
        help.ctx = Context.new
        help.call([], nil)
        raise ShopifyCli::AbortSilent
      else
        super(args)
      end
    end
  end
end
