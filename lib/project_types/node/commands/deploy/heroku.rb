# frozen_string_literal: true
require "shopify_cli"

module Node
  class Command
    class Deploy
      class Heroku
        def self.help
          ShopifyCLI::Context.message("node.deploy.heroku.help", ShopifyCLI::TOOL_NAME)
        end

        def self.start(ctx)
          spin_group = CLI::UI::SpinGroup.new
          heroku_service = ShopifyCLI::Heroku.new(ctx)

          spin_group.add(ctx.message("node.deploy.heroku.downloading")) do |spinner|
            heroku_service.download
            spinner.update_title(ctx.message("node.deploy.heroku.downloaded"))
          end
          spin_group.wait

          install_message = ctx.message(
            ctx.windows? ? "node.deploy.heroku.installing_windows" : "node.deploy.heroku.installing"
          )
          spin_group.add(install_message) do |spinner|
            heroku_service.install
            spinner.update_title(ctx.message("node.deploy.heroku.installed"))
          end
          spin_group.wait

          spin_group.add(ctx.message("node.deploy.heroku.git.checking")) do |spinner|
            ShopifyCLI::Git.init(ctx)
            spinner.update_title(ctx.message("node.deploy.heroku.git.initialized"))
          end
          spin_group.wait

          if (account = heroku_service.whoami)
            ctx.puts(ctx.message("node.deploy.heroku.authenticated_with_account", account))
          else
            CLI::UI::Frame.open(
              ctx.message("node.deploy.heroku.authenticating"),
              success_text: ctx.message("node.deploy.heroku.authenticated")
            ) do
              heroku_service.authenticate
            end
          end

          if (app_name = heroku_service.app)
            ctx.puts(ctx.message("node.deploy.heroku.app.selected", app_name))
          else
            app_type = CLI::UI::Prompt.ask(ctx.message("node.deploy.heroku.app.no_apps_found")) do |handler|
              handler.option(ctx.message("node.deploy.heroku.app.create")) { :new }
              handler.option(ctx.message("node.deploy.heroku.app.select")) { :existing }
            end

            if app_type == :existing
              app_name = CLI::UI::Prompt.ask(ctx.message("node.deploy.heroku.app.name"))
              CLI::UI::Frame.open(
                ctx.message("node.deploy.heroku.app.selecting", app_name),
                success_text: ctx.message("node.deploy.heroku.app.selected", app_name)
              ) do
                heroku_service.select_existing_app(app_name)
              end
            elsif app_type == :new
              CLI::UI::Frame.open(
                ctx.message("node.deploy.heroku.app.creating"),
                success_text: ctx.message("node.deploy.heroku.app.created")
              ) do
                heroku_service.create_new_app
              end
            end
          end

          branches = ShopifyCLI::Git.branches(ctx)
          if branches.length == 1
            branch_to_deploy = branches[0]
            ctx.puts(ctx.message("node.deploy.heroku.git.branch_selected", branch_to_deploy))
          else
            branch_to_deploy = CLI::UI::Prompt.ask(ctx.message("node.deploy.heroku.git.what_branch")) do |handler|
              branches.each do |branch|
                handler.option(branch) { branch }
              end
            end
          end

          CLI::UI::Frame.open(
            ctx.message("node.deploy.heroku.deploying"),
            success_text: ctx.message("node.deploy.heroku.deployed")
          ) do
            heroku_service.deploy(branch_to_deploy)
          end
        end
      end
    end
  end
end
