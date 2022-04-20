module ShopifyCLI
  module Commands
    class App
      class Serve < ShopifyCLI::Command::AppSubCommand
        include ShopifyCLI::CommandOptions::CommandServeOptions

        prerequisite_task :ensure_env, :ensure_dev_store

        recommend_default_ruby_range

        parse_host_option
        parse_port_option
        parse_no_update_option

        def call(*)
          case detect_app
          when :rails
            Services::App::Serve::RailsService.call(
              host: host,
              port: port,
              no_update: no_update,
              context: @ctx
            )
          when :node
            Services::App::Serve::NodeService.call(
              host: host,
              port: port,
              no_update: no_update,
              context: @ctx
            )
          when :php
            Services::App::Serve::PHPService.call(
              host: host,
              port: port,
              no_update: no_update,
              context: @ctx
            )
          end
        end

        def self.help
          ShopifyCLI::Context.message("core.app.serve.help", ShopifyCLI::TOOL_NAME, ShopifyCLI::TOOL_NAME)
        end

        def self.extended_help
          ShopifyCLI::Context.message("core.app.serve.extended_help")
        end
      end
    end
  end
end
