module ShopifyCLI
  class Command
    class AppCommand < Command
      def call(*)
        @ctx.puts(self.class.help)
      end

      class << self
        def help
          project_type = name.split("::")[0].downcase
          ShopifyCLI::Context.message(
            "#{project_type}.help",
            ShopifyCLI::TOOL_NAME,
            subcommand_registry.command_names.join(" | ")
          )
        end

        def call_help(*)
          @ctx.puts(help)
        end
      end
    end
  end
end
