require 'test_helper'

module ShopifyCli
  class HerokuTest < MiniTest::Test
    def setup
      super

      @download_filename = 'heroku-darwin-x64.tar.gz'
      @download_path = File.join(ShopifyCli::ROOT, @download_filename)
      @heroku_path = File.join(ShopifyCli::ROOT, 'heroku', 'bin', 'heroku').to_s
      @heroku_remote = 'https://git.heroku.com/app-name.git'

      @status_mock = {
        false: mock,
        true: mock,
      }
      @status_mock[:false].stubs(:success?).returns(false)
      @status_mock[:true].stubs(:success?).returns(true)

      File.stubs(:exist?).returns(false)
      stub_os(os: :mac)
    end

    def test_app_uses_existing_heroku_app_if_available
      stub_git_remote_get_url(status: true, remote: 'heroku')

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_equal 'app-name', heroku_service.app
    end

    def test_app_returns_nil_if_choosing_existing_heroku_app_fails
      stub_git_remote_get_url(status: false, remote: 'heroku')

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.app)
    end

    def test_authenticate_uses_existing_heroku_auth_if_available
      stub_heroku_login(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.authenticate)
    end

    def test_authenticate_uses_local_path_heroku_existing_auth_if_available
      File.stubs(:exist?).returns(true)
      stub_heroku_login(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.authenticate)
    end

    def test_authenticate_raises_if_heroku_auth_fails
      stub_heroku_login(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.authenticate
      end
    end

    def test_create_new_app_lets_you_create_new_heroku_app
      File.stubs(:exist?).returns(true)
      stub_git_create(status: true, heroku_path: @heroku_path)
      stub_git_remote_add(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.create_new_app)
    end

    def test_create_new_app_raises_if_creating_new_heroku_app_fails
      stub_git_create(status: false, heroku_path: 'heroku')
      stub_git_remote_add(status: nil)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.create_new_app
      end
    end

    def test_create_new_app_raises_if_setting_remote_heroku_fails
      stub_git_create(status: true, heroku_path: 'heroku')
      stub_git_remote_add(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.create_new_app
      end
    end

    def test_deploy_tries_to_deploy_to_heroku
      stub_heroku_deploy(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.deploy("master"))
    end

    def test_deploy_raises_if_deploy_fails
      stub_heroku_deploy(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.deploy("master")
      end
    end

    def test_download_doesnt_download_heroku_cli_if_it_is_installed
      stub_heroku_installed(status: true)
      stub_heroku_download(status: nil)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.download)
    end

    def test_download_downloads_heroku_cli_if_it_is_not_installed
      stub_heroku_installed(status: false)
      stub_heroku_download(status: true)
      stub_heroku_download_exists(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.download)
    end

    def test_download_raises_if_heroku_cli_download_fails
      stub_heroku_installed(status: false)
      stub_heroku_download(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.download
      end
    end

    def test_download_raises_if_heroku_cli_download_is_missing
      stub_heroku_installed(status: false)
      stub_heroku_download(status: true)
      stub_heroku_download_exists(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.download
      end
    end

    def test_install_doesnt_install_heroku_cli_if_it_is_already_installed
      stub_heroku_installed(status: true)
      stub_tar(status: nil)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.install)
    end

    def test_install_installs_heroku_cli_if_it_is_downloaded
      stub_heroku_installed(status: false)
      stub_tar(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert heroku_service.install
    end

    def test_install_raises_if_heroku_cli_install_fails
      stub_heroku_installed(status: false)
      stub_tar(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.install
      end
    end

    def test_select_existing_app_lets_you_choose_existing_heroku_app
      stub_heroku_select_app(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.select_existing_app('app-name'))
    end

    def test_select_existing_app_raises_if_choosing_existing_heroku_app_fails
      stub_heroku_select_app(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_raises ShopifyCli::Abort do
        heroku_service.select_existing_app('app-name')
      end
    end

    def test_whoami_returns_username_if_logged_in
      stub_heroku_whoami(status: true)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_equal 'username', heroku_service.whoami
    end

    def test_whoami_returns_nil_if_not_logged_in
      stub_heroku_whoami(status: false)

      heroku_service = ShopifyCli::Heroku.new(@context)

      assert_nil(heroku_service.whoami)
    end

    private

    def stub_git_remote_get_url(status:, remote:)
      output = if status == true
        @heroku_remote
      else
        "fatal: No such remote '#{remote}'"
      end

      @context.stubs(:capture2e)
        .with('git', 'remote', 'get-url', remote)
        .returns([output, @status_mock[:"#{status}"]])
    end

    def stub_git_remote_add(status:)
      if status.nil?
        @context.expects(:system)
          .with('git', 'remote', 'add', 'heroku', @heroku_remote)
          .never
      else
        @context.expects(:system)
          .with('git', 'remote', 'add', 'heroku', @heroku_remote)
          .returns(@status_mock[:"#{status}"])
      end
    end

    def stub_git_create(status:, heroku_path: 'heroku')
      output = <<~EOS
        Creating app... done, ⬢ app-name
        https://app-name.herokuapp.com/ | #{@heroku_remote}
      EOS

      @context.expects(:capture2e)
        .with(heroku_path, 'create')
        .returns([output, @status_mock[:"#{status}"]])
    end

    def stub_heroku_login(status:)
      @context.stubs(:system)
        .with(@heroku_path, 'login')
        .returns(@status_mock[:"#{status}"])

      @context.stubs(:system)
        .with('heroku', 'login')
        .returns(@status_mock[:"#{status}"])
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

    def stub_heroku_download(status:)
      if status.nil?
        @context.stubs(:system)
          .with('curl', '-o', @download_path,
          ShopifyCli::Heroku::DOWNLOAD_URLS[:mac],
          chdir: ShopifyCli::ROOT)
          .never
      else
        @context.stubs(:system)
          .with('curl', '-o', @download_path,
            ShopifyCli::Heroku::DOWNLOAD_URLS[:mac],
            chdir: ShopifyCli::ROOT)
          .returns(@status_mock[:"#{status}"])
      end
    end

    def stub_heroku_installed(status:)
      File.stubs(:exist?)
        .with(@heroku_path)
        .returns(status)

      @context.stubs(:capture2e)
        .with(@heroku_path, '--version')
        .returns(['', @status_mock[:"#{status}"]])

      @context.stubs(:capture2e)
        .with('heroku', '--version')
        .returns(['', @status_mock[:"#{status}"]])
    end

    def stub_tar(status:)
      if status.nil?
        @context.stubs(:system)
          .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
          .never
      else
        @context.stubs(:system)
          .with('tar', '-xf', @download_path, chdir: ShopifyCli::ROOT)
          .returns(@status_mock[:"#{status}"])
      end

      if status
        @context.stubs(:rm).with(@download_path).returns(status)
      else
        @context.stubs(:rm).with(@download_path).never
      end
    end

    def stub_heroku_select_app(status:)
      File.stubs(:exist?).returns(true)

      @context.stubs(:system)
        .with(@heroku_path, 'git:remote', '-a', 'app-name')
        .returns(@status_mock[:"#{status}"])
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

    def stub_os(os:)
      ShopifyCli::Context.any_instance.stubs(:os).returns(os)
    end
  end
end
