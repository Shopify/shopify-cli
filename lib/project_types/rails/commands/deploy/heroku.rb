# frozen_string_literal: true
require "shopify_cli"

module Rails
  class Command
    class Deploy
      class Heroku
        class << self
          DB_CHECK_CMD = 'bundle exec rails runner "puts ActiveRecord::Base.connection.adapter_name.downcase"'

          def help
            ShopifyCLI::Context.message("rails.deploy.heroku.help", ShopifyCLI::TOOL_NAME)
          end

          def start(ctx)
            CLI::UI::Frame.open(ctx.message("rails.deploy.heroku.db_check.validating")) do
              CLI::UI::Spinner.spin(ctx.message("rails.deploy.heroku.db_check.checking")) do |spinner|
                db_type, err = check_db(ctx)
                ctx.abort(ctx.message(err)) unless err.nil?
                spinner.update_title(ctx.message("rails.deploy.heroku.db_check.validated", db_type))
              end
              true
            end

            spin_group = CLI::UI::SpinGroup.new
            heroku_service = ShopifyCLI::Heroku.new(ctx)

            spin_group.add(ctx.message("rails.deploy.heroku.downloading")) do |spinner|
              heroku_service.download
              spinner.update_title(ctx.message("rails.deploy.heroku.downloaded"))
            end
            spin_group.wait

            spin_group.add(ctx.message("rails.deploy.heroku.installing")) do |spinner|
              heroku_service.install
              spinner.update_title(ctx.message("rails.deploy.heroku.installed"))
            end
            spin_group.add(ctx.message("rails.deploy.heroku.git.checking")) do |spinner|
              ShopifyCLI::Git.init(ctx)
              spinner.update_title(ctx.message("rails.deploy.heroku.git.initialized"))
            end
            spin_group.wait

            if (account = heroku_service.whoami)
              ctx.puts(ctx.message("rails.deploy.heroku.authenticated_with_account", account))
            else
              CLI::UI::Frame.open(
                ctx.message("rails.deploy.heroku.authenticating"),
                success_text: ctx.message("rails.deploy.heroku.authenticated")
              ) do
                heroku_service.authenticate
              end
            end

            if (app_name = heroku_service.app)
              ctx.puts(ctx.message("rails.deploy.heroku.app.selected", app_name))
            else
              app_type = CLI::UI::Prompt.ask(ctx.message("rails.deploy.heroku.app.no_apps_found")) do |handler|
                handler.option(ctx.message("rails.deploy.heroku.app.create")) { :new }
                handler.option(ctx.message("rails.deploy.heroku.app.select")) { :existing }
              end

              if app_type == :existing
                app_name = CLI::UI::Prompt.ask(ctx.message("rails.deploy.heroku.app.name"))
                CLI::UI::Frame.open(
                  ctx.message("rails.deploy.heroku.app.selecting", app_name),
                  success_text: ctx.message("rails.deploy.heroku.app.selected", app_name)
                ) do
                  heroku_service.select_existing_app(app_name)
                end
              elsif app_type == :new
                CLI::UI::Frame.open(
                  ctx.message("rails.deploy.heroku.app.creating"),
                  success_text: ctx.message("rails.deploy.heroku.app.created")
                ) do
                  heroku_service.create_new_app
                end
              end
            end

            branches = ShopifyCLI::Git.branches(ctx)
            if branches.length == 1
              branch_to_deploy = branches[0]
              ctx.puts(ctx.message("rails.deploy.heroku.git.branch_selected", branch_to_deploy))
            else
              branch_to_deploy = CLI::UI::Prompt.ask(ctx.message("rails.deploy.heroku.git.what_branch")) do |handler|
                branches.each do |branch|
                  handler.option(branch) { branch }
                end
              end
            end

            CLI::UI::Frame.open(
              ctx.message("rails.deploy.heroku.deploying"),
              success_text: ctx.message("rails.deploy.heroku.deployed")
            ) do
              heroku_service.deploy(branch_to_deploy)
            end
          end

          def check_db(ctx)
            out, stat = ctx.capture2e(DB_CHECK_CMD)
            if stat.success? && out.strip == "sqlite"
              ["sqlite", "rails.deploy.heroku.db_check.sqlite"]
            elsif !stat.success?
              [nil, "rails.deploy.heroku.db_check.problem"]
            else
              [out.strip, nil]
            end
          end
        end
      end
    end
  end
end
