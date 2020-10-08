require 'test_helper'
require 'fileutils'

module ShopifyCli
  class ShopifolkTest < MiniTest::Test
    FEATURE_NAME = "shopifolk"
    def test_correct_features_is_shopifolk
      ShopifyCli::Feature.disable(FEATURE_NAME)
      Dir.mktmpdir do |dev_dir|
        FileUtils.mkdir_p("#{dev_dir}/bin")
        FileUtils.touch("#{dev_dir}/bin/dev")
        FileUtils.touch("#{dev_dir}/.shopify-build")
        ShopifyCli::Shopifolk.check
      end
      assert ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    def test_feature_always_returns_true_without_debug
      ShopifyCli::Feature.enable(FEATURE_NAME)
      assert ShopifyCli::Shopifolk.check
    end

    def test_no_gcloud_config_disables_shopifolk_feature
      ShopifyCli::Feature.enable(FEATURE_NAME)
      ShopifyCli::Feature.stubs(:enabled?).with(FEATURE_NAME).returns(false)
      File.expects(:exist?).with(::ShopifyCli::Shopifolk::GCLOUD_CONFIG_FILE).returns(false)
      ShopifyCli::Shopifolk.check
      refute ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    def test_no_section_in_gcloud_config_disables_shopifolk_feature
      ShopifyCli::Feature.enable(FEATURE_NAME)
      ShopifyCli::Feature.stubs(:enabled?).with(FEATURE_NAME).returns(false)
      stub_ini({ "account" => "test@shopify.com", "project" => "shopify-dev" })
      ShopifyCli::Shopifolk.check
      refute ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    def test_no_account_in_gcloud_config_disables_shopifolk_feature
      ShopifyCli::Feature.enable(FEATURE_NAME)
      ShopifyCli::Feature.stubs(:enabled?).with(FEATURE_NAME).returns(false)
      stub_ini({ "[core]" => { "project" => "shopify-dev" } })
      ShopifyCli::Shopifolk.check
      refute ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    def test_incorrect_email_in_gcloud_config_disables_shopifolk_feature
      ShopifyCli::Feature.enable(FEATURE_NAME)
      ShopifyCli::Feature.stubs(:enabled?).with(FEATURE_NAME).returns(false)
      stub_ini({ "[core]" => { "account" => "test@test.com", "project" => "shopify-dev" } })
      ShopifyCli::Shopifolk.check
      refute ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    def test_incorrect_dev_path_disables_dev_shopifolk_feature
      ShopifyCli::Feature.enable(FEATURE_NAME)
      ShopifyCli::Feature.stubs(:enabled?).with(FEATURE_NAME).returns(false)
      File.expects(:exist?).twice.with(::ShopifyCli::Shopifolk::GCLOUD_CONFIG_FILE).returns(true)
      File.expects(:exist?).with("#{::ShopifyCli::Shopifolk::DEV_PATH}/bin/dev").returns(false)
      ShopifyCli::Shopifolk.check
      refute ShopifyCli::Config.get_bool(Feature::SECTION, FEATURE_NAME)
    end

    private

    def stub_ini(ret_val)
      ini = CLI::Kit::Ini.new
      ini.expects(:parse).returns(ini)
      ini.expects(:ini).returns(ret_val)
      CLI::Kit::Ini.expects(:new).returns(ini)
    end
  end
end
