module ShopifyCLI
  module Services
    module App
      module Deploy
        module Heroku
          class NodeService < BaseService
            attr_reader :context

            def initialize(context:)
              @context = context
              super()
            end

            def call
              spin_group = CLI::UI::SpinGroup.new
              heroku_service = ShopifyCLI::Heroku.new(context)

              spin_group.add(context.message("core.app.deploy.heroku.downloading")) do |spinner|
                heroku_service.download
                spinner.update_title(context.message("core.app.deploy.heroku.downloaded"))
              end
              spin_group.wait

              install_message = context.message(
                context.windows? ? "core.app.deploy.heroku.installing_windows" : "core.app.deploy.heroku.installing"
              )
              spin_group.add(install_message) do |spinner|
                heroku_service.install
                spinner.update_title(context.message("core.app.deploy.heroku.installed"))
              end
              spin_group.wait

              spin_group.add(context.message("core.app.deploy.heroku.git.checking")) do |spinner|
                ShopifyCLI::Git.init(context)
                spinner.update_title(context.message("core.app.deploy.heroku.git.initialized"))
              end
              spin_group.wait

              if (account = heroku_service.whoami)
                context.puts(context.message("core.app.deploy.heroku.authenticated_with_account", account))
              else
                CLI::UI::Frame.open(
                  context.message("core.app.deploy.heroku.authenticating"),
                  success_text: context.message("core.app.deploy.heroku.authenticated")
                ) do
                  heroku_service.authenticate
                end
              end

              if (app_name = heroku_service.app)
                context.puts(context.message("core.app.deploy.heroku.app.selected", app_name))
              else
                app_type = CLI::UI::Prompt.ask(context.message("core.app.deploy.heroku.app.no_apps_found")) do |handler|
                  handler.option(context.message("core.app.deploy.heroku.app.create")) { :new }
                  handler.option(context.message("core.app.deploy.heroku.app.select")) { :existing }
                end

                if app_type == :existing
                  app_name = CLI::UI::Prompt.ask(context.message("core.app.deploy.heroku.app.name"))
                  CLI::UI::Frame.open(
                    context.message("core.app.deploy.heroku.app.selecting", app_name),
                    success_text: context.message("core.app.deploy.heroku.app.selected", app_name)
                  ) do
                    heroku_service.select_existing_app(app_name)
                  end
                elsif app_type == :new
                  CLI::UI::Frame.open(
                    context.message("core.app.deploy.heroku.app.creating"),
                    success_text: context.message("core.app.deploy.heroku.app.created")
                  ) do
                    heroku_service.create_new_app
                  end
                end
              end

              branches = ShopifyCLI::Git.branches(context)
              if branches.length == 1
                branch_to_deploy = branches[0]
                context.puts(context.message("core.app.deploy.heroku.git.branch_selected", branch_to_deploy))
              else
                prompt_question = context.message("core.app.deploy.heroku.git.what_branch")
                branch_to_deploy = CLI::UI::Prompt.ask(prompt_question) do |handler|
                  branches.each do |branch|
                    handler.option(branch) { branch }
                  end
                end
              end

              CLI::UI::Frame.open(
                context.message("core.app.deploy.heroku.deploying"),
                success_text: context.message("core.app.deploy.heroku.deployed")
              ) do
                heroku_service.deploy(branch_to_deploy)
              end
            end
          end
        end
      end
    end
  end
end
