module ShopifyCli
  class ProjectCommands < Command
    def call(*)
      @ctx.puts(self.class.help)
    end

    def self.help
      project_type = name.split("::")[0].downcase
      ShopifyCli::Context.message(
        "#{project_type}.help",
        ShopifyCli::TOOL_NAME,
        subcommand_registry.command_names.join(" | ")
      )
    end
  end
end
