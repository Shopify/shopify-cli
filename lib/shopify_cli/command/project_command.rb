module ShopifyCLI
  class Command
    class ProjectCommand < Command
      def call(*)
        @ctx.puts(self.class.help)
      end

      class << self
        def help
          project_type = name.split("::")[0].downcase
          ShopifyCLI::Context.message(
            "#{project_type}.help",
            ShopifyCLI::TOOL_NAME,
            available_subcommands
          )
        end

        private

        def available_subcommands
          subcommand_registry
            .resolved_commands
            .reject { |_name, command| command.hidden? }
            .keys
            .sort
            .join(" | ")
        end
      end
    end
  end
end
