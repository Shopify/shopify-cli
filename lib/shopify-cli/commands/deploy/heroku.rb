require 'shopify_cli'

module ShopifyCli
  module Commands
    class Deploy
      class Heroku < ShopifyCli::Task
        include Helpers::OS

        DOWNLOAD_URLS = {
          linux: 'https://cli-assets.heroku.com/heroku-linux-x64.tar.gz',
          mac: 'https://cli-assets.heroku.com/heroku-darwin-x64.tar.gz',
          windows: 'https://cli-assets.heroku.com/heroku-win32-x64.tar.gz',
        }

        def self.help
          <<~HELP
            Deploy the current app project to Heroku
            Usage: {{command:#{ShopifyCli::TOOL_NAME} deploy heroku}}
          HELP
        end

        def call(ctx, _name = nil)
          @ctx = ctx

          spin_group = CLI::UI::SpinGroup.new

          spin_group.add('Downloading Heroku CLI…') do |spinner|
            heroku_download
            spinner.update_title('Downloaded Heroku CLI')
          end
          spin_group.wait

          spin_group.add('Installing Heroku CLI…') do |spinner|
            heroku_install
            spinner.update_title('Installed Heroku CLI')
          end
          spin_group.add('Checking git repo…') do |spinner|
            git_init
            spinner.update_title('Git repo initialized')
          end
          spin_group.wait

          if (account = heroku_whoami)
            spin_group.add("Authenticated with Heroku as `#{account}`") { true }
            spin_group.wait
          else
            CLI::UI::Frame.open("Authenticating with Heroku…", success_text: '{{v}} Authenticated with Heroku') do
              heroku_authenticate
            end
          end

          if (app_name = heroku_app)
            spin_group.add("Heroku app `#{app_name}` selected") { true }
            spin_group.wait
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
                heroku_select_existing_app(app_name)
              end
            elsif app_type == :new
              CLI::UI::Frame.open('Creating new Heroku app…', success_text: '{{v}} New Heroku app created') do
                heroku_create_new_app
              end
            end
          end

          branches = git_branches
          if branches.length == 1
            branch_to_deploy = branches[0]
            spin_group.add("Git branch `#{branch_to_deploy}` selected for deploy") { true }
            spin_group.wait
          else
            branch_to_deploy = CLI::UI::Prompt.ask('What branch would you like to deploy?') do |handler|
              branches.each do |branch|
                handler.option(branch) { branch }
              end
            end
          end

          CLI::UI::Frame.open('Deploying to Heroku…', success_text: '{{v}} Deployed to Heroku') do
            heroku_deploy(branch_to_deploy)
          end
        end

        private

        def git_branches
          output, status = @ctx.capture2e('git', 'branch', '--list', '--format=%(refname:short)')
          raise(ShopifyCli::Abort, "Could not find any git branches") unless status.success?

          branches = if output == ''
            ['master']
          else
            output.split("\n")
          end

          branches
        end

        def git_init
          output, status = @ctx.capture2e('git', 'status')

          unless status.success?
            raise(ShopifyCli::Abort, "Git repo is not initiated. Please run `git init` and make at least one commit.")
          end

          if output.include?('No commits yet')
            raise(ShopifyCli::Abort, "No git commits have been made. Please make at least one commit.")
          end
        end

        def heroku_app
          return nil if heroku_git_remote.nil?
          app = heroku_git_remote
          app = app.split('/').last
          app = app.split('.').first
          app
        end

        def heroku_authenticate
          result = @ctx.system(heroku_command, 'login')
          raise(ShopifyCli::Abort, "Could not authenticate with Heroku") unless result.success?
        end

        def heroku_command
          local_path = File.join(ShopifyCli::ROOT, 'heroku', 'bin', 'heroku').to_s
          if File.exist?(local_path)
            local_path
          else
            'heroku'
          end
        end

        def heroku_create_new_app
          output, status = @ctx.capture2e(heroku_command, 'create')
          raise(ShopifyCli::Abort, 'Heroku app could not be created') unless status.success?
          @ctx.puts(output)

          new_remote = output.split("\n").last.split("|").last.strip
          result = @ctx.system('git', 'remote', 'add', 'heroku', new_remote)
          raise(ShopifyCli::Abort, 'Heroku app created, but couldn’t be set as a git remote') unless result.success?
        end

        def heroku_deploy(branch_to_deploy)
          result = @ctx.system('git', 'push', '-u', 'heroku', "#{branch_to_deploy}:master")
          raise(ShopifyCli::Abort, "Could not deploy to Heroku") unless result.success?
        end

        def heroku_download
          return if heroku_installed?

          result = @ctx.system('curl', '-o', heroku_download_path, DOWNLOAD_URLS[os], chdir: ShopifyCli::ROOT)
          raise(ShopifyCli::Abort, "Heroku CLI could not be downloaded") unless result.success?
          raise(ShopifyCli::Abort, "Heroku CLI could not be downloaded") unless File.exist?(heroku_download_path)
        end

        def heroku_download_filename
          URI.parse(DOWNLOAD_URLS[os]).path.split('/').last
        end

        def heroku_download_path
          File.join(ShopifyCli::ROOT, heroku_download_filename)
        end

        def heroku_git_remote
          output, status = @ctx.capture2e('git', 'remote', 'get-url', 'heroku')
          status.success? ? output : nil
        end

        def heroku_install
          return if heroku_installed?

          result = @ctx.system('tar', '-xf', heroku_download_path, chdir: ShopifyCli::ROOT)
          raise(ShopifyCli::Abort, "Could not install Heroku CLI") unless result.success?

          FileUtils.rm(heroku_download_path)
        end

        def heroku_installed?
          _output, status = @ctx.capture2e(heroku_command, '--version')
          status.success?
        rescue
          false
        end

        def heroku_select_existing_app(app_name)
          result = @ctx.system(heroku_command, 'git:remote', '-a', app_name)
          raise(ShopifyCli::Abort, "Heroku app `#{app_name}` could not be selected") unless result.success?
        end

        def heroku_whoami
          output, status = @ctx.capture2e(heroku_command, 'whoami')
          return output.strip if status.success?
          nil
        end
      end
    end
  end
end
