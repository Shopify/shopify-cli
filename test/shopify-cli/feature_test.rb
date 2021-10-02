require "test_helper"

module ShopifyCLI
  class FeatureTest < MiniTest::Test
    include TestHelpers::FakeFS

    TEST_FEATURE = :feature_set_flag_test

    class TestClass
      extend Feature::Set
      hidden_feature feature_set: TEST_FEATURE
    end

    def test_set_controls_hidden
      Feature.enable(TEST_FEATURE)
      refute TestClass.hidden?
      Feature.disable(TEST_FEATURE)
      assert TestClass.hidden?
    end

    def test_enable_sets_true_bool
      Feature.enable(TEST_FEATURE)
      assert ShopifyCLI::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
    end

    def test_disable_sets_false_bool
      Feature.disable(TEST_FEATURE)
      refute ShopifyCLI::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
    end

    def test_enabled_returns_bool_status
      Feature.enable(TEST_FEATURE)
      assert ShopifyCLI::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
      assert Feature.enabled?(TEST_FEATURE)
      Feature.disable(TEST_FEATURE)
      refute ShopifyCLI::Config.get_bool(Feature::SECTION, TEST_FEATURE.to_s)
      refute Feature.enabled?(TEST_FEATURE)
      refute Feature.enabled?(nil)
    end
  end
end
