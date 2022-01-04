# typed: ignore
require "test_helper"
require "fileutils"

module ShopifyCLI
  class ShopifolkTest < MiniTest::Test
    include TestHelpers::FakeFS

    def setup
      super
      ShopifyCLI::Feature.disable("shopifolk")
    end

    def teardown
      ShopifyCLI::DB.stubs(:del).with(:acting_as_shopify_organization)
      super
    end

    def test_correct_features_is_shopifolk
      FileUtils.mkdir_p("/opt/dev/bin")
      FileUtils.touch("/opt/dev/bin/dev")
      FileUtils.touch("/opt/dev/.shopify-build")
      stub_gcloud_ini({ "[core]" => { "account" => "test@shopify.com", "project" => "shopify-dev" } })

      ShopifyCLI::Shopifolk.check

      assert ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_feature_always_returns_true
      ShopifyCLI::Feature.enable("shopifolk")

      assert ShopifyCLI::Shopifolk.check
    end

    def test_no_gcloud_config_disables_shopifolk_feature
      refute ShopifyCLI::Config.get_bool("features", "shopifolk")

      ShopifyCLI::Shopifolk.check

      refute ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_no_section_in_gcloud_config_disables_shopifolk_feature
      stub_gcloud_ini({ "account" => "test@shopify.com", "project" => "shopify-dev" })

      ShopifyCLI::Shopifolk.check

      refute ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_no_account_in_gcloud_config_disables_shopifolk_feature
      stub_gcloud_ini({ "[core]" => { "project" => "shopify-dev" } })

      ShopifyCLI::Shopifolk.check

      refute ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_incorrect_email_in_gcloud_config_disables_shopifolk_feature
      stub_gcloud_ini({ "[core]" => { "account" => "test@test.com", "project" => "shopify-dev" } })

      ShopifyCLI::Shopifolk.check

      refute ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_incorrect_dev_path_disables_dev_shopifolk_feature
      stub_gcloud_ini({ "[core]" => { "account" => "test@shopify.com", "project" => "shopify-dev" } })

      ShopifyCLI::Shopifolk.check

      refute ShopifyCLI::Config.get_bool("features", "shopifolk")
    end

    def test_setting_act_as_shopify_organization
      ShopifyCLI::DB.expects(:get).with(:acting_as_shopify_organization).returns(nil)
      refute ShopifyCLI::Shopifolk.acting_as_shopify_organization?

      ShopifyCLI::DB.expects(:set).with(acting_as_shopify_organization: true)
      ShopifyCLI::Shopifolk.act_as_shopify_organization

      ShopifyCLI::DB.expects(:get).with(:acting_as_shopify_organization).returns(true)
      assert ShopifyCLI::Shopifolk.acting_as_shopify_organization?

      ShopifyCLI::DB.expects(:del).with(:acting_as_shopify_organization)
      ShopifyCLI::Shopifolk.reset

      ShopifyCLI::DB.expects(:get).with(:acting_as_shopify_organization).returns(nil)
      refute ShopifyCLI::Shopifolk.acting_as_shopify_organization?
    end

    def test_reading_shopify_organization_from_config
      ShopifyCLI::DB.expects(:get).with(:acting_as_shopify_organization).returns(nil)
      Project.expects(:has_current?).returns(true)
      project = stub("project", config: { "shopify_organization" => true })
      Project.expects(:current).returns(project)

      assert ShopifyCLI::Shopifolk.acting_as_shopify_organization?
    end

    private

    def stub_gcloud_ini(ret_val)
      FileUtils.mkdir_p(File.expand_path("~/.config/gcloud/configurations"))
      FileUtils.touch(File.expand_path("~/.config/gcloud/configurations/config_default"))
      ini = CLI::Kit::Ini.new
      ini.expects(:parse).returns(ini)
      ini.expects(:ini).returns(ret_val)
      CLI::Kit::Ini.expects(:new).returns(ini)
    end
  end
end
