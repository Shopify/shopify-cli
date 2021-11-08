require "test_helper"

module ShopifyCLI
  module Services
    module App
      module Deploy
        module Heroku
          class RailsServiceTest < MiniTest::Test
            include TestHelpers::FakeUI
            include TestHelpers::Heroku

            def setup
              super
              File.stubs(:exist?)
              File.stubs(:exist?).with(File.join(ShopifyCLI::ROOT, "lib", "project_types", "rails",
                "cli.rb")).returns(true)
              @context.stubs(:os).returns(:mac)
              stub_successful_heroku_flow
            end

            def test_call_raises_if_using_sqlite
              expects_heroku_db_validated(status: false, db: "sqlite")

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_raises_if_cannot_validate_db
              expects_heroku_db_validated(status: false, db: nil)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_validates_db_if_not_sqlite
              expects_heroku_db_validated(status: true, db: "mysql")
              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_doesnt_download_heroku_cli_if_it_is_installed
              expects_heroku_installed(status: true, twice: true)
              expects_heroku_download(status: nil)
              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_downloads_heroku_cli_if_it_is_not_installed
              expects_heroku_installed(status: false)
              expects_heroku_download(status: true)
              expects_heroku_download_exists(status: true)

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_heroku_cli_download_fails
              expects_heroku_installed(status: false)
              expects_heroku_download(status: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_raises_if_heroku_cli_download_is_missing
              expects_heroku_installed(status: false)
              expects_heroku_download_exists(status: false)
              expects_heroku_download(status: true)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_doesnt_install_heroku_cli_if_it_is_already_installed
              expects_heroku_installed(status: true, twice: true)
              expects_tar_heroku(status: nil)

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_installs_heroku_cli_if_it_is_downloaded
              expects_heroku_download(status: true)
              expects_heroku_download_exists(status: true)
              expects_heroku_installed(status: false, twice: true)
              expects_tar_heroku(status: true)

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_heroku_cli_install_fails
              expects_heroku_download(status: true)
              expects_heroku_download_exists(status: true)
              expects_heroku_installed(status: false, twice: true)
              expects_tar_heroku(status: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_raises_if_git_isnt_inited
              expects_git_init_heroku(status: false, commits: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_raises_if_git_is_inited_but_there_are_no_commits
              expects_git_init_heroku(status: true, commits: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_uses_existing_heroku_auth_if_available
              expects_heroku_whoami(status: true)

              @context.expects(:puts).with(@context.message("core.app.deploy.heroku.authenticated_with_account",
                "username"))

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_attempts_to_authenticate_with_heroku_if_not_already_authed
              expects_heroku_whoami(status: false)
              expects_heroku_login(status: true)

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_heroku_auth_fails
              expects_heroku_whoami(status: false)
              expects_heroku_login(status: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_uses_existing_heroku_app_if_available
              expects_git_remote_get_url_heroku(status: true, remote: "heroku")

              @context.expects(:puts).with(@context.message("core.app.deploy.heroku.authenticated_with_account",
                "username"))

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_lets_you_choose_existing_heroku_app
              expects_git_remote_get_url_heroku(status: false, remote: "heroku")
              expects_heroku_select_app(status: true)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.no_apps_found"))
                .returns(:existing)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.name"))
                .returns("app-name")

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_choosing_existing_heroku_app_fails
              expects_git_remote_get_url_heroku(status: false, remote: "heroku")
              expects_heroku_select_app(status: false)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.no_apps_found"))
                .returns(:existing)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.name"))
                .returns("app-name")

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_lets_you_create_new_heroku_app
              expects_git_remote_get_url_heroku(status: false, remote: "heroku")
              expects_heroku_create(status: true)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.no_apps_found"))
                .returns(:new)

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_creating_new_heroku_app_fails
              expects_git_remote_get_url_heroku(status: false, remote: "heroku")
              expects_heroku_create(status: false)

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.app.no_apps_found"))
                .returns(:new)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_doesnt_prompt_if_only_one_branch_exists
              expects_git_branch(status: true, multiple: false)

              @context.expects(:puts).with(@context.message("core.app.deploy.heroku.git.branch_selected", "master"))

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_lets_you_specify_a_branch_if_multiple_exist
              expects_git_branch(status: true, multiple: true)
              expects_git_push_heroku(status: true, branch: "other_branch:master")

              CLI::UI::Prompt.expects(:ask)
                .with(@context.message("core.app.deploy.heroku.git.what_branch"))
                .returns("other_branch")

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_finding_branches_fails
              expects_git_branch(status: false, multiple: false)

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end

            def test_call_successfully_deploys_to_heroku
              expects_git_push_heroku(status: true, branch: "master:master")

              Services::App::Deploy::Heroku::RailsService.call(context: @context)
            end

            def test_call_raises_if_deploy_to_heroku_fails
              expects_git_push_heroku(status: false, branch: "master:master")

              assert_raises ShopifyCLI::Abort do
                Services::App::Deploy::Heroku::RailsService.call(context: @context)
              end
            end
          end
        end
      end
    end
  end
end
