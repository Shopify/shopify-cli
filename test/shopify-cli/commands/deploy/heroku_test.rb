require 'test_helper'

module ShopifyCli
  module Commands
    class Deploy
      class HerokuTest < MiniTest::Test
        include TestHelpers::FakeUI

        def setup
          super

          @download_filename = 'heroku-darwin-x64.tar.gz'
          @download_path = File.join(ShopifyCli::ROOT, @download_filename)
          @heroku_command = File.join(ShopifyCli::ROOT, 'heroku', 'bin', 'heroku').to_s
          @heroku_remote = 'https://git.heroku.com/app-name.git'

          @status_mock = {
            false: mock,
            true: mock,
          }
          @status_mock[:false].stubs(:success?).returns(false)
          @status_mock[:true].stubs(:success?).returns(true)

          File.stubs(:exist?)

          stub_successful_flow(os: :mac)
        end

        def test_call_doesnt_download_heroku_cli_if_it_is_installed
          @context.expects(:system)
            .with('curl', '-o', @download_path,
              Deploy::Heroku::DOWNLOAD_URLS[:mac],
              chdir: ShopifyCli::ROOT)
            .never

          run_cmd('deploy heroku')
        end

        def test_call_downloads_heroku_cli_if_it_is_not_installed
          stub_heroku_installed(status: false)

          @context.expects(:system)
            .with('curl', '-o', @download_path,
              Deploy::Heroku::DOWNLOAD_URLS[:mac],
              chdir: ShopifyCli::ROOT)
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_cli_download_fails
          stub_heroku_installed(status: false)

          assert_raises ShopifyCli::Abort do
            @context.expects(:system)
              .with('curl', '-o', @download_path,
                Deploy::Heroku::DOWNLOAD_URLS[:mac],
                chdir: ShopifyCli::ROOT)
              .returns(@status_mock[:false])

            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_heroku_cli_download_is_missing
          stub_heroku_installed(status: false)
          stub_heroku_download_exists(status: false)

          assert_raises ShopifyCli::Abort do
            @context.expects(:system)
              .with('curl', '-o', @download_path,
                Deploy::Heroku::DOWNLOAD_URLS[:mac],
                chdir: ShopifyCli::ROOT)
              .returns(@status_mock[:true])

            run_cmd('deploy heroku')
          end
        end

        def test_call_doesnt_install_heroku_cli_if_it_is_already_installed
          @context.expects(:system)
            .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
            .never

          run_cmd('deploy heroku')
        end

        def test_call_installs_heroku_cli_if_it_is_downloaded
          stub_heroku_installed(status: false)

          @context.expects(:system)
            .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_cli_install_fails
          stub_heroku_installed(status: false)

          assert_raises ShopifyCli::Abort do
            @context.expects(:system)
              .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
              .returns(@status_mock[:false])

            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_git_isnt_inited
          stub_git_init(status: false, commits: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_git_is_inited_but_there_are_no_commits
          stub_git_init(status: true, commits: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_uses_existing_heroku_auth_if_available
          @context.expects(:capture2e)
            .with(@heroku_command, 'whoami')
            .returns(['username', @status_mock[:true]])

          CLI::UI::SpinGroup.any_instance.expects(:add).with(
            'Authenticated with Heroku as `username`'
          )

          capture_io do
            run_cmd('deploy heroku')
          end
        end

        def test_call_attempts_to_authenticate_with_heroku_if_not_already_authed
          stub_heroku_whoami(status: false)

          @context.expects(:system)
            .with(@heroku_command, 'login')
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_heroku_auth_fails
          stub_heroku_whoami(status: false)
          stub_heroku_login(status: false)

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_uses_existing_heroku_app_if_available
          @context.expects(:capture2e)
            .with('git', 'remote', 'get-url', 'heroku')
            .returns([@heroku_remote, @status_mock[:true]])

          CLI::UI::SpinGroup.any_instance.expects(:add).with(
            'Heroku app `app-name` selected'
          )

          capture_io do
            run_cmd('deploy heroku')
          end
        end

        def test_call_lets_you_choose_existing_heroku_app
          stub_git_remote(status: false, remote: 'heroku')

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:existing)

          CLI::UI::Prompt.expects(:ask)
            .with('What is your Heroku app’s name?')
            .returns('app-name')

          @context.expects(:system)
            .with(@heroku_command, 'git:remote', '-a', 'app-name')
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_choosing_existing_heroku_app_fails
          stub_git_remote(status: false, remote: 'heroku')

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:existing)

          CLI::UI::Prompt.expects(:ask)
            .with('What is your Heroku app’s name?')
            .returns('app-name')

          @context.expects(:system)
            .with(@heroku_command, 'git:remote', '-a', 'app-name')
            .returns(@status_mock[:false])

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_lets_you_create_new_heroku_app
          stub_git_remote(status: false, remote: 'heroku')

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:new)

          output = <<~EOS
            Creating app... done, ⬢ app-name
            https://app-name.herokuapp.com/ | #{@heroku_remote}
          EOS

          @context.expects(:capture2e)
            .with(@heroku_command, 'create')
            .returns([output, @status_mock[:true]])

          @context.expects(:system)
            .with('git', 'remote', 'add', 'heroku', @heroku_remote)
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_creating_new_heroku_app_fails
          stub_git_remote(status: false, remote: 'heroku')

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:new)

          @context.expects(:capture2e)
            .with(@heroku_command, 'create')
            .returns(['', @status_mock[:false]])

          @context.expects(:system)
            .with('git', 'remote', 'add', 'heroku', @heroku_remote)
            .never

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_raises_if_setting_remote_heroku_fails
          stub_git_remote(status: false, remote: 'heroku')

          CLI::UI::Prompt.expects(:ask)
            .with('No existing Heroku app found. What would you like to do?')
            .returns(:new)

          output = <<~EOS
            Creating app... done, ⬢ app-name
            https://app-name.herokuapp.com/ | #{@heroku_remote}
          EOS

          @context.expects(:capture2e)
            .with(@heroku_command, 'create')
            .returns([output, @status_mock[:true]])

          @context.expects(:system)
            .with('git', 'remote', 'add', 'heroku', @heroku_remote)
            .returns(@status_mock[:false])

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_doesnt_prompt_if_only_one_branch_exists
          @context.expects(:capture2e)
            .with('git', 'branch', '--list', '--format=%(refname:short)')
            .returns(["master\n", @status_mock[:true]])

          CLI::UI::SpinGroup.any_instance.expects(:add).with(
            'Git branch `master` selected for deploy'
          )

          capture_io do
            run_cmd('deploy heroku')
          end
        end

        def test_call_lets_you_specify_a_branch_if_multiple_exist
          stub_git_branches(multiple: true)

          CLI::UI::Prompt.expects(:ask)
            .with('What branch would you like to deploy?')
            .returns('other_branch')

          @context.expects(:system)
            .with('git', 'push', '-u', 'heroku', "other_branch:master")
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_finding_branches_fails
          @context.stubs(:capture2e)
            .with('git', 'branch', '--list', '--format=%(refname:short)')
            .returns(['', @status_mock[:false]])

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        def test_call_tries_to_deploy_to_heroku
          @context.expects(:system)
            .with('git', 'push', '-u', 'heroku', "master:master")
            .returns(@status_mock[:true])

          run_cmd('deploy heroku')
        end

        def test_call_raises_if_deploy_fails
          @context.expects(:system)
            .with('git', 'push', '-u', 'heroku', "master:master")
            .returns(@status_mock[:false])

          assert_raises ShopifyCli::Abort do
            run_cmd('deploy heroku')
          end
        end

        private

        def stub_successful_flow(os:)
          stub_git_init(status: true, commits: true)
          stub_os(os: os)
          stub_heroku_downloaded(status: true)
          stub_heroku_download_exists(status: true)
          stub_tar(status: true)
          stub_heroku_installed(status: true)
          stub_heroku_whoami(status: true)
          stub_heroku_login(status: true)
          stub_heroku_select_app(status: true)
          stub_git_remote(status: true, remote: 'heroku')
          stub_git_remote(status: true, remote: 'origin')
          stub_git_branches(multiple: false)
          stub_heroku_deploy(status: true)
        end

        def stub_git_branches(multiple:)
          output = "master\n"
          output << "other_branch\n" if multiple

          @context.stubs(:capture2e)
            .with('git', 'branch', '--list', '--format=%(refname:short)')
            .returns([output, @status_mock[:true]])
        end

        def stub_git_init(status:, commits:)
          output = if commits == true
            <<~EOS
              On branch master
              Your branch is up to date with 'heroku/master'.

              nothing to commit, working tree clean
            EOS
          else
            <<~EOS
              On branch master

              No commits yet
            EOS
          end

          @context.stubs(:capture2e)
            .with('git', 'status')
            .returns([output, @status_mock[:"#{status}"]])
        end

        def stub_git_remote(status:, remote:)
          output = if status == true
            @heroku_remote
          else
            "fatal: No such remote '#{remote}'"
          end

          @context.stubs(:capture2e)
            .with('git', 'remote', 'get-url', remote)
            .returns([output, @status_mock[:"#{status}"]])
        end

        def stub_heroku_deploy(status:)
          @context.stubs(:system)
            .with('git', 'push', '-u', 'heroku', "master:master")
            .returns(@status_mock[:"#{status}"])
        end

        def stub_heroku_download_exists(status:)
          File.stubs(:exist?)
            .with(@download_path)
            .returns(status)
        end

        def stub_heroku_downloaded(status:)
          @context.stubs(:system)
            .with('curl', '-o', @download_path,
              Deploy::Heroku::DOWNLOAD_URLS[:mac],
              chdir: ShopifyCli::ROOT)
            .returns(@status_mock[:"#{status}"])
        end

        def stub_heroku_installed(status:)
          File.stubs(:exist?)
            .with(@heroku_command)
            .returns(status)

          @context.stubs(:capture2e)
            .with(@heroku_command, '--version')
            .returns(['', @status_mock[:"#{status}"]])

          @context.stubs(:capture2e)
            .with('heroku', '--version')
            .returns(['', @status_mock[:"#{status}"]])
        end

        def stub_heroku_login(status:)
          @context.stubs(:system)
            .with(@heroku_command, 'login')
            .returns(@status_mock[:"#{status}"])

          @context.stubs(:system)
            .with('heroku', 'login')
            .returns(@status_mock[:"#{status}"])
        end

        def stub_heroku_select_app(status:)
          @context.stubs(:capture2e)
            .with(@heroku_command, 'git:remote', '-a', 'app-name')
            .returns(['', @status_mock[:"#{status}"]])

          @context.stubs(:capture2e)
            .with(@heroku_command, 'git:remote', '-a', 'app-name')
            .returns(['', @status_mock[:"#{status}"]])
        end

        def stub_heroku_whoami(status:)
          output = status ? 'username' : nil

          @context.stubs(:capture2e)
            .with(@heroku_command, 'whoami')
            .returns([output, @status_mock[:"#{status}"]])

          @context.stubs(:capture2e)
            .with('heroku', 'whoami')
            .returns([output, @status_mock[:"#{status}"]])
        end

        def stub_tar(status:)
          @context.stubs(:system)
            .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
            .returns(@status_mock[:"#{status}"])

          FileUtils.stubs(:rm)
            .with(@download_path)
            .returns(status)
        end

        def stub_os(os:)
          Heroku.any_instance.stubs(:os).returns(os)
        end
      end
    end
  end
end
