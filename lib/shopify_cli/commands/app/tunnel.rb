require "project_types/node/cli"

module ShopifyCLI
  module Commands
    class App
      class Tunnel < ShopifyCLI::Command::AppSubCommand
        def call(args, _name)
          subcommand = args.shift
          case subcommand
          when "start"
            Services::App::Tunnel::StartService.call(
              context: @ctx
            )
          when "stop"
            Services::App::Tunnel::StopService.call(
              context: @ctx
            )
          else
            @ctx.puts(self.class.help)
          end
        end

        def self.help
          ShopifyCLI::Context.message("core.app.tunnel.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end

        def self.extended_help
          ShopifyCLI::Context.message("core.app.tunnel.extended_help", ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
