module ShopifyCLI
  module Commands
    class App
      class Open < ShopifyCLI::Command::AppSubCommand
        def call(*)
          project = ShopifyCLI::Project.current
          Services::App::OpenService.call(
            project: project,
            context: @ctx
          )
        end

        def self.help
          ShopifyCLI::Context.message("core.app.open.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
