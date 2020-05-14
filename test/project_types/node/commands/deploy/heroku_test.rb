require 'test_helper'

module Node
  module Commands
    module DeployTests
      class HerokuTest < MiniTest::Test
        include TestHelpers::FakeUI
        include TestHelpers::Heroku

        def setup
          super
          File.stubs(:exist?)
          File.stubs(:exist?).with(File.join(ShopifyCli::ROOT, 'lib', 'project_types', 'node', 'cli.rb')).returns(true)
          ShopifyCli::ProjectType.load_type(:node)
          ShopifyCli::Context.any_instance.stubs(:os).returns(:mac)
          stub_successful_heroku_flow
        end

        def test_help_argument_calls_help
          @context.expects(:puts).with(Node::Commands::Deploy::Heroku.help)
          run_cmd('help deploy heroku')
        end

        def test_call_doesnt_download_heroku_cli_if_it_is_installed
          expects_heroku_installed(status: true, twice: true)
          expects_heroku_download(status: nil)

          run_cmd('deploy heroku')
        end

        def test_call_downloads_heroku_cli_if_it_is_not_installed
          expects_heroku_installed(status: false)
          expects_heroku_download(status: true)
          expects_heroku_download_exists(status: true)

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_cli_download_fails
          expects_heroku_installed(status: false)
          expects_heroku_download(status: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_heroku_cli_download_is_missing
          expects_heroku_installed(status: false)
          expects_heroku_download_exists(status: false)
          expects_heroku_download(status: true)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_doesnt_install_heroku_cli_if_it_is_already_installed
          expects_heroku_installed(status: true, twice: true)
          expects_tar_heroku(status: nil)

          run_cmd('deploy heroku')
        end

        def test_call_installs_heroku_cli_if_it_is_downloaded
          expects_heroku_download(status: true)
          expects_heroku_download_exists(status: true)
          expects_heroku_installed(status: false, twice: true)
          expects_tar_heroku(status: true)

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_cli_install_fails
          expects_heroku_download(status: true)
          expects_heroku_download_exists(status: true)
          expects_heroku_installed(status: false, twice: true)
          expects_tar_heroku(status: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_git_isnt_inited
          expects_git_init_heroku(status: false, commits: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_git_is_inited_but_there_are_no_commits
          expects_git_init_heroku(status: true, commits: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_uses_existing_heroku_auth_if_available
          expects_heroku_whoami(status: true)

          @context.expects(:puts).with(
            '{{v}} Authenticated with Heroku as `username`'
          )

          run_cmd('deploy heroku')
        end

        def test_call_attempts_to_authenticate_with_heroku_if_not_already_authed
          expects_heroku_whoami(status: false)
          expects_heroku_login(status: true)

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_auth_fails
          expects_heroku_whoami(status: false)
          expects_heroku_login(status: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_uses_existing_heroku_app_if_available
          expects_git_remote_get_url_heroku(status: true, remote: 'heroku')

          @context.expects(:puts).with(
            '{{v}} Heroku app `app-name` selected'
          )

          run_cmd('deploy heroku')
        end

        def test_call_lets_you_choose_existing_heroku_app
          expects_git_remote_get_url_heroku(status: false, remote: 'heroku')
          expects_heroku_select_app(status: true)

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:existing)

          CLI::UI::Prompt.expects(:ask)
            .with('What is your Heroku app’s name?')
            .returns('app-name')

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_choosing_existing_heroku_app_fails
          expects_git_remote_get_url_heroku(status: false, remote: 'heroku')
          expects_heroku_select_app(status: false)

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:existing)

          CLI::UI::Prompt.expects(:ask)
            .with('What is your Heroku app’s name?')
            .returns('app-name')

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_lets_you_create_new_heroku_app
          expects_git_remote_get_url_heroku(status: false, remote: 'heroku')
          expects_heroku_create(status: true)

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:new)

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_creating_new_heroku_app_fails
          expects_git_remote_get_url_heroku(status: false, remote: 'heroku')
          expects_heroku_create(status: false)

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:new)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_doesnt_prompt_if_only_one_branch_exists
          expects_git_branch(status: true, multiple: false)

          @context.expects(:puts).with(
            '{{v}} Git branch `master` selected for deploy'
          )

          run_cmd('deploy heroku')
        end

        def test_call_lets_you_specify_a_branch_if_multiple_exist
          expects_git_branch(status: true, multiple: true)
          expects_git_push_heroku(status: true, branch: "other_branch:master")

          CLI::UI::Prompt.expects(:ask)
            .with('What branch would you like to deploy?')
            .returns('other_branch')

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_finding_branches_fails
          expects_git_branch(status: false, multiple: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_successfully_deploys_to_heroku
          expects_git_push_heroku(status: true, branch: "master:master")

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_deploy_to_heroku_fails
          expects_git_push_heroku(status: false, branch: "master:master")

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end
      end
    end
  end
end
