require 'test_helper'

module ShopifyCli
  class ShopifolkTest < MiniTest::Test
    GCLOUD_FEATURE_NAME = 'gcloud_shopifolk'
    DEV_FEATURE_NAME = 'dev_shopifolk'

    def test_correct_features_is_shopifolk
      gcloud_path = '../shopifolk_correct.conf'
      ShopifyCli::Feature.disable(GCLOUD_FEATURE_NAME)
      ShopifyCli::Feature.disable(DEV_FEATURE_NAM)
      Dir.mktmpdir do |dev_dir|
        FileUtils.mkdir_p("#{dev_dir}/bin")
        FileUtils.touch("#{dev_dir}/bin/dev")
        FileUtils.touch("#{dev_dir}/.shopify-build")
        ShopifyCli::Shopifolk.new.shopifolk?(gcloud_path, dev_dir)
      end
      assert ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME)
      assert ShopifyCli::Config.get_bool(Feature::SECTION, DEV_FEATURE_NAME)
    end

    def test_incorrect_gcloud_disables_shopifolk_feature
      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME)
      path_no_core = 'shopifolk_incorrect_no_core.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_core)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME)

      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME)
      path_no_account = '../shopifolk_incorrect_no_account.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_account)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME)

      ShopifyCli::Feature.enable(GCLOUD_FEATURE_NAME)
      path_no_email = '../shopifolk_incorrect_no_email.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_email)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, GCLOUD_FEATURE_NAME)
    end

    def test_incorrect_dev_path_disables_dev_shopifolk_feature
      fake_path = "/fakepath"
      ShopifyCli::Feature.enable(DEV_FEATURE_NAME)
      ShopifyCli::Shopifolk.new.shopifolk?(fake_path, fake_path)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, DEV_FEATURE_NAME)
    end
  end
end
