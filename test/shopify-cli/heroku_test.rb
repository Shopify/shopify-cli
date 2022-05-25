require "test_helper"

module ShopifyCLI
  class HerokuTest < MiniTest::Test
    include TestHelpers::Heroku

    def setup
      super
      File.stubs(:exist?).returns(false)
      ShopifyCLI::Context.any_instance.stubs(:os).returns(:mac)
    end

    def test_app_uses_existing_heroku_app_if_available
      expects_git_remote_get_url_heroku(status: true, remote: "heroku")

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_equal "app-name", heroku_service.app
    end

    def test_app_returns_nil_if_choosing_existing_heroku_app_fails
      expects_git_remote_get_url_heroku(status: false, remote: "heroku")

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.app)
    end

    def test_authenticate_using_full_path_heroku_existing_auth_if_available
      expects_heroku_login(status: true, full_path: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.authenticate)
    end

    def test_authenticate_using_non_full_path_heroku_existing_auth_if_available
      expects_heroku_login(status: true, full_path: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.authenticate)
    end

    def test_authenticate_raises_if_heroku_auth_fails
      expects_heroku_login(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.authenticate
      end
    end

    def test_create_new_app_using_full_path_heroku_to_create_new_heroku_app
      expects_heroku_create(status: true, full_path: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.create_new_app)
    end

    def test_create_new_app_using_non_full_path_heroku_to_create_new_heroku_app
      expects_heroku_create(status: true, full_path: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.create_new_app)
    end

    def test_create_new_app_raises_if_creating_new_heroku_app_fails
      expects_heroku_create(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.create_new_app
      end
    end

    def test_deploy_tries_to_deploy_to_heroku
      expects_heroku_deploy(status: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.deploy("master"))
    end

    def test_deploy_raises_if_deploy_fails
      expects_heroku_deploy(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.deploy("master")
      end
    end

    def test_download_doesnt_download_heroku_cli_if_it_is_installed
      expects_heroku_installed(status: true)
      expects_heroku_download(status: nil)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.download)
    end

    [:linux, :mac, :mac_m1, :windows].each do |os|
      define_method("test_download_downloads_heroku_cli_if_it_is_not_installed_for_#{os}") do
        ShopifyCLI::Context.any_instance.stubs(:os).returns(os)
        
        expects_heroku_installed(status: false)
        expects_heroku_download(status: true, os: os)
        expects_heroku_download_exists(status: true, os: os)
        
        heroku_service = ShopifyCLI::Heroku.new(@context)
        
        assert_nil(heroku_service.download)
      end
    end

    def test_download_raises_if_heroku_cli_download_fails
      expects_heroku_installed(status: false)
      expects_heroku_download(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.download
      end
    end

    def test_download_raises_if_heroku_cli_download_is_missing
      expects_heroku_installed(status: false)
      expects_heroku_download(status: true)
      expects_heroku_download_exists(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.download
      end
    end

    def test_install_doesnt_install_heroku_cli_if_it_is_already_installed
      expects_heroku_installed(status: true)
      expects_tar_heroku(status: nil)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.install)
    end

    def test_install_using_full_path_heroku_and_installs_heroku_cli_if_it_is_downloaded
      expects_heroku_installed(status: false, full_path: true)
      expects_tar_heroku(status: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert heroku_service.install
    end

    def test_install_using_non_full_path_heroku_and_installs_heroku_cli_if_it_is_downloaded
      expects_heroku_installed(status: false, full_path: false)
      expects_tar_heroku(status: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert heroku_service.install
    end

    def test_install_raises_if_heroku_cli_install_fails
      expects_heroku_installed(status: false)
      expects_tar_heroku(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.install
      end
    end

    def test_select_existing_app_using_full_path_heroku_lets_you_choose_existing_heroku_app
      expects_heroku_select_app(status: true, full_path: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.select_existing_app("app-name"))
    end

    def test_select_existing_app_using_non_full_path_heroku_lets_you_choose_existing_heroku_app
      expects_heroku_select_app(status: true, full_path: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.select_existing_app("app-name"))
    end

    def test_select_existing_app_raises_if_choosing_existing_heroku_app_fails
      expects_heroku_select_app(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_raises ShopifyCLI::Abort do
        heroku_service.select_existing_app("app-name")
      end
    end

    def test_whoami_using_full_path_heroku_returns_username_if_logged_in
      expects_heroku_whoami(status: true, full_path: true)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_equal "username", heroku_service.whoami
    end

    def test_whoami_using_non_full_path_heroku_returns_username_if_logged_in
      expects_heroku_whoami(status: true, full_path: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_equal "username", heroku_service.whoami
    end

    def test_whoami_returns_nil_if_not_logged_in
      expects_heroku_whoami(status: false)

      heroku_service = ShopifyCLI::Heroku.new(@context)

      assert_nil(heroku_service.whoami)
    end
  end
end
