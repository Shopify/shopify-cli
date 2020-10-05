require 'test_helper'

module ShopifyCli
  class ShopifolkTest < MiniTest::Test
    TEST_FEATURE = :shopifolk

    def test_correct_gcloud_enables_shopifolk_feature
      path = '../shopifolk_correct.conf'
      ShopifyCli::Feature.disable(TEST_FEATURE.to_s)
      ShopifyCli::Shopifolk.new.shopifolk?(path)
      assert ShopifyCli::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
    end

    def test_incorrect_gcloud_disables_shopifolk_feature
      ShopifyCli::Feature.enable(TEST_FEATURE.to_s)
      path_no_core = '../shopifolk_incorrect_no_core.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_core)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)

      ShopifyCli::Feature.enable(TEST_FEATURE.to_s)
      path_no_account = '../shopifolk_incorrect_no_account.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_account)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)

      ShopifyCli::Feature.enable(TEST_FEATURE.to_s)
      path_no_email = '../shopifolk_incorrect_no_email.conf'
      ShopifyCli::Shopifolk.new.shopifolk?(path_no_email)
      refute ShopifyCli::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
    end
  end
end
