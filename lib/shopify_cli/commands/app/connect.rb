module ShopifyCLI
  module Commands
    class App
      class Connect < ShopifyCLI::Command::AppSubCommand
        def call(_args, _command_name, *)
          app_type = detect_app(directory: Dir.pwd)
          project = ShopifyCLI::Project.current

          Services::App::ConnectService.call(
            app_type: app_type,
            project: project,
            context: @ctx
          )
        end

        def self.help
          ShopifyCLI::Context.message("core.app.connect.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
