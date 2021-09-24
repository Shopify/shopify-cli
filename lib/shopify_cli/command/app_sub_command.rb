module ShopifyCLI
  class Command
    class AppSubCommand < SubCommand
      class << self
        def call_help(*)
          @ctx.puts(help)
        end
      end
    end
  end
end
