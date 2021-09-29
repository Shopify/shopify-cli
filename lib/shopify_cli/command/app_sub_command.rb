module ShopifyCLI
  class Command
    class AppSubCommand < SubCommand
      class << self
        def call_help(*)
          output = help
          if respond_to?(:extended_help)
            output += "\n"
            output += extended_help
          end
          @ctx.puts(output)
        end
      end
    end
  end
end
