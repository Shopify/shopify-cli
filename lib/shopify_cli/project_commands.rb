module ShopifyCLI
  class ProjectCommands < Command
    def call(*)
      @ctx.puts(self.class.help)
    end

    def self.help
      project_type = name.split("::")[0].downcase
      ShopifyCLI::Context.message(
        "#{project_type}.help",
        ShopifyCLI::TOOL_NAME,
        available_commands
      )
    end

    private

      def available_commands
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
