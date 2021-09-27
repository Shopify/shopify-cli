module ShopifyCLI
  class ProjectCommand < Command
    def call(*)
      @ctx.puts(self.class.help)
    end

    def self.help
      project_type = name.split("::")[0].downcase
      ShopifyCLI::Context.message(
        "#{project_type}.help",
        ShopifyCLI::TOOL_NAME,
        subcommand_registry.command_names.join(" | ")
      )
    end
  end
end
