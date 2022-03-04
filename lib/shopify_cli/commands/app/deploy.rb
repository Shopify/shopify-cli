module ShopifyCLI
  module Commands
    class App
      class Deploy < ShopifyCLI::Command::AppSubCommand
        prerequisite_task :ensure_git_dependency

        recommend_default_ruby_range

        def call(args, _name)
          platform = args.shift
          case platform
          when "heroku"
            case detect_app
            when :rails
              Services::App::Deploy::Heroku::RailsService.call(
                context: @ctx
              )
            when :php
              Services::App::Deploy::Heroku::PHPService.call(
                context: @ctx
              )
            when :node
              Services::App::Deploy::Heroku::NodeService.call(
                context: @ctx
              )
            end
          when nil
            raise ShopifyCLI::Abort, @ctx.message(
              "core.app.deploy.error.missing_platform",
              ShopifyCLI::TOOL_NAME
            )
          else
            raise ShopifyCLI::Abort, @ctx.message(
              "core.app.deploy.error.invalid_platform",
              platform,
              ShopifyCLI::TOOL_NAME
            )
          end
        end

        def self.help
          ShopifyCLI::Context.message("core.app.deploy.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end

        def self.extended_help
          ShopifyCLI::Context.message("core.app.deploy.extended_help", ShopifyCLI::TOOL_NAME)
        end
      end
    end
  end
end
