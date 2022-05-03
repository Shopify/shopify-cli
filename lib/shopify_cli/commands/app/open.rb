module ShopifyCLI
  module Commands
    class App
      class Open < ShopifyCLI::Command::AppSubCommand
        def call(*)
          project = ShopifyCLI::Project.current

          case detect_app
          when :rails
            Services::App::Open::OpenService.call(
              project: project,
              context: @ctx
            )
          when :node
            Services::App::Open::NodeService.call(
              project: project,
              context: @ctx
            )
          when :php
            Services::App::Open::OpenService.call(
              project: project,
              context: @ctx
            )
          end
        end

        def self.help
          ShopifyCLI::Context.message("core.app.open.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
