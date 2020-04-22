# frozen_string_literal: true
require 'shopify_cli'

module Rails
  module Commands
    class Deploy
      class Heroku < ShopifyCli::SubCommand
        def self.help
          <<~HELP
            Deploy the current Rails project to Heroku
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy heroku}}
          HELP
        end

        def call(_args, _name)
          spin_group = CLI::UI::SpinGroup.new
          heroku_service = ShopifyCli::Heroku.new(@ctx)

          spin_group.add('Downloading Heroku CLI…') do |spinner|
            heroku_service.download
            spinner.update_title('Downloaded Heroku CLI')
          end
          spin_group.wait

          spin_group.add('Installing Heroku CLI…') do |spinner|
            heroku_service.install
            spinner.update_title('Installed Heroku CLI')
          end
          spin_group.add('Checking git repo…') do |spinner|
            ShopifyCli::Git.init(@ctx)
            spinner.update_title('Git repo initialized')
          end
          spin_group.wait

          if (account = heroku_service.whoami)
            @ctx.puts("{{v}} Authenticated with Heroku as `#{account}`")
          else
            CLI::UI::Frame.open("Authenticating with Heroku…", success_text: '{{v}} Authenticated with Heroku') do
              heroku_service.authenticate
            end
          end

          if (app_name = heroku_service.app)
            @ctx.puts("{{v}} Heroku app `#{app_name}` selected")
          else
            app_type = CLI::UI::Prompt.ask('No existing Heroku app found. What would you like to do?') do |handler|
              handler.option('Create a new Heroku app') { :new }
              handler.option('Specify an existing Heroku app') { :existing }
            end

            if app_type == :existing
              app_name = CLI::UI::Prompt.ask('What is your Heroku app’s name?')
              CLI::UI::Frame.open(
                "Selecting Heroku app `#{app_name}`…",
                success_text: "{{v}} Heroku app `#{app_name}` selected"
              ) do
                heroku_service.select_existing_app(app_name)
              end
            elsif app_type == :new
              CLI::UI::Frame.open('Creating new Heroku app…', success_text: '{{v}} New Heroku app created') do
                heroku_service.create_new_app
              end
            end
          end

          branches = ShopifyCli::Git.branches(@ctx)
          if branches.length == 1
            branch_to_deploy = branches[0]
            @ctx.puts("{{v}} Git branch `#{branch_to_deploy}` selected for deploy")
          else
            branch_to_deploy = CLI::UI::Prompt.ask('What branch would you like to deploy?') do |handler|
              branches.each do |branch|
                handler.option(branch) { branch }
              end
            end
          end

          CLI::UI::Frame.open('Deploying to Heroku…', success_text: '{{v}} Deployed to Heroku') do
            heroku_service.deploy(branch_to_deploy)
          end
        end
      end
    end
  end
end
