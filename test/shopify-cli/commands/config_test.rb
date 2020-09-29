require 'test_helper'

module ShopifyCli
  module Commands
    class ConfigTest < MiniTest::Test
      TEST_FEATURE = :feature_flag_test

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
        run_cmd('config help')
      end

      def test_no_arguments_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
        run_cmd('config')
      end

      def test_no_feature_calls_help
        @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
        run_cmd('config feature')
      end

      def test_will_enable_a_feature_that_is_disabled
        ShopifyCli::Feature.disable(TEST_FEATURE)
        @context.expects(:puts).with(@context.message('core.config.feature.enabled', TEST_FEATURE))
        run_cmd("config feature #{TEST_FEATURE} --enable")
        assert ShopifyCli::Feature.enabled?(TEST_FEATURE)
      end

      def test_will_disable_a_feature_that_is_enabled
        ShopifyCli::Feature.enable(TEST_FEATURE)
        @context.expects(:puts).with(@context.message('core.config.feature.disabled', TEST_FEATURE))
        run_cmd("config feature #{TEST_FEATURE} --disable")
        refute ShopifyCli::Feature.enabled?(TEST_FEATURE)
      end
    end
  end
end
