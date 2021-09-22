# frozen_string_literal: true
require "shopify_cli"

module PHP
  class Command
    class Deploy
      class Heroku
        def self.help
          ShopifyCLI::Context.message("php.deploy.heroku.help", ShopifyCLI::TOOL_NAME)
        end

        def self.start(ctx)
          spin_group = CLI::UI::SpinGroup.new
          heroku_service = ShopifyCLI::Heroku.new(ctx)

          spin_group.add(ctx.message("php.deploy.heroku.downloading")) do |spinner|
            heroku_service.download
            spinner.update_title(ctx.message("php.deploy.heroku.downloaded"))
          end
          spin_group.wait

          install_message = ctx.message(
            ctx.windows? ? "php.deploy.heroku.installing_windows" : "php.deploy.heroku.installing"
          )
          spin_group.add(install_message) do |spinner|
            heroku_service.install
            spinner.update_title(ctx.message("php.deploy.heroku.installed"))
          end
          spin_group.wait

          spin_group.add(ctx.message("php.deploy.heroku.git.checking")) do |spinner|
            ShopifyCLI::Git.init(ctx)
            spinner.update_title(ctx.message("php.deploy.heroku.git.initialized"))
          end
          spin_group.wait

          if (account = heroku_service.whoami)
            ctx.puts(ctx.message("php.deploy.heroku.authenticated_with_account", account))
          else
            CLI::UI::Frame.open(
              ctx.message("php.deploy.heroku.authenticating"),
              success_text: ctx.message("php.deploy.heroku.authenticated")
            ) do
              heroku_service.authenticate
            end
          end

          if (app_name = heroku_service.app)
            ctx.puts(ctx.message("php.deploy.heroku.app.selected", app_name))
          else
            app_type = CLI::UI::Prompt.ask(ctx.message("php.deploy.heroku.app.no_apps_found")) do |handler|
              handler.option(ctx.message("php.deploy.heroku.app.create")) { :new }
              handler.option(ctx.message("php.deploy.heroku.app.select")) { :existing }
            end

            if app_type == :existing
              app_name = CLI::UI::Prompt.ask(ctx.message("php.deploy.heroku.app.name"))
              CLI::UI::Frame.open(
                ctx.message("php.deploy.heroku.app.selecting", app_name),
                success_text: ctx.message("php.deploy.heroku.app.selected", app_name)
              ) do
                heroku_service.select_existing_app(app_name)
              end
            elsif app_type == :new
              CLI::UI::Frame.open(
                ctx.message("php.deploy.heroku.app.creating"),
                success_text: ctx.message("php.deploy.heroku.app.created")
              ) do
                heroku_service.create_new_app
                app_name = heroku_service.app
              end
            end
          end

          branches = ShopifyCLI::Git.branches(ctx)
          if branches.length == 1
            branch_to_deploy = branches[0]
            ctx.puts(ctx.message("php.deploy.heroku.git.branch_selected", branch_to_deploy))
          else
            branch_to_deploy = CLI::UI::Prompt.ask(ctx.message("php.deploy.heroku.git.what_branch")) do |handler|
              branches.each do |branch|
                handler.option(branch) { branch }
              end
            end
          end

          app_url = "https://#{app_name}.herokuapp.com"

          CLI::UI::Frame.open(
            ctx.message("php.deploy.heroku.app.setting_configs"),
            success_text: ctx.message("php.deploy.heroku.app.configs_set")
          ) do
            allowed_configs = [/SHOPIFY_API_KEY/, /SHOPIFY_API_SECRET/, /SCOPES/, /HOST/]

            ShopifyCLI::Project.current.env.to_h.each do |config, value|
              next unless allowed_configs.any? { |pattern| pattern.match?(config) }

              value = app_url if config == "HOST"

              current = heroku_service.get_config(config)
              heroku_service.set_config(config, value) if current.nil? || current != value
            end

            current_key = heroku_service.get_config("APP_KEY")
            if current_key.nil? || current_key.empty?
              output, status = ctx.capture2e("php", "artisan", "key:generate", "--show")

              ctx.abort(ctx.message("php.deploy.heroku.error.generate_app_key")) unless status.success?

              heroku_service.set_config("APP_KEY", output.strip) if status.success?
            end

            heroku_service.add_buildpacks(["heroku/php", "heroku/nodejs"])
          end

          CLI::UI::Frame.open(
            ctx.message("php.deploy.heroku.deploying"),
            success_text: ctx.message("php.deploy.heroku.deployed")
          ) do
            heroku_service.deploy(branch_to_deploy)
          end

          heroku_command = heroku_service.heroku_command
          ctx.puts(ctx.message("php.deploy.heroku.post_deploy", app_url, heroku_command))
        end
      end
    end
  end
end
