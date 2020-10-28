require 'test_helper'

module ShopifyCli
  module Commands
    class ConfigTest < MiniTest::Test
      include TestHelpers::FakeFS

      TEST_FEATURE = :feature_flag_test

      def test_help_argument_calls_help
        with_logging_stubbed_out do
          @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
          run_cmd('config help')
        end
      end

      def test_feature_help_argument_calls_help
        with_logging_stubbed_out do
          @context.expects(:puts).with(ShopifyCli::Commands::Config::Feature.help)
          run_cmd('config feature --help')
        end
      end

      def test_analytics_help_argument_calls_help
        with_logging_stubbed_out do
          @context.expects(:puts).with(ShopifyCli::Commands::Config::Analytics.help)
          run_cmd('config analytics --help')
        end
      end

      def test_no_arguments_calls_help
        with_logging_stubbed_out do
          @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
          run_cmd('config')
        end
      end

      def test_no_feature_calls_help
        with_logging_stubbed_out do
          @context.expects(:puts).with(ShopifyCli::Commands::Config.help)
          run_cmd('config feature')
        end
      end

      def test_will_enable_a_feature_that_is_disabled
        with_logging_stubbed_out do
          ShopifyCli::Feature.disable(TEST_FEATURE)
          @context.expects(:puts).with(@context.message('core.config.feature.enabled', TEST_FEATURE))
          run_cmd("config feature #{TEST_FEATURE} --enable")
          assert ShopifyCli::Feature.enabled?(TEST_FEATURE)
        end
      end

      def test_will_disable_a_feature_that_is_enabled
        with_logging_stubbed_out do
          ShopifyCli::Feature.enable(TEST_FEATURE)
          @context.expects(:puts).with(@context.message('core.config.feature.disabled', TEST_FEATURE))
          run_cmd("config feature #{TEST_FEATURE} --disable")
          refute ShopifyCli::Feature.enabled?(TEST_FEATURE)
        end
      end

      def test_will_enable_analytics_that_is_disabled
        with_logging_stubbed_out do
          ShopifyCli::Config.set('analytics', 'enabled', false)
          run_cmd("config analytics --enable")
          assert ShopifyCli::Config.get_bool('analytics', 'enabled')
        end
      end

      def test_will_disable_analytics_that_is_enabled
        with_logging_stubbed_out do
          ShopifyCli::Config.set('analytics', 'enabled', true)
          run_cmd("config analytics --disable")
          refute ShopifyCli::Config.get_bool('analytics', 'enabled')
        end
      end

      private

      # NOTE: This is using minitest's own mocking rather than Mocha, as Mocha
      # doesn't appear to provide a way to swap out a method's implementation
      def with_logging_stubbed_out(&test_block)
        ShopifyCli::Core::Monorail.stub(
          :log,
          ->(*_args, &block) { block.call },
        ) do
          test_block.call
        end
      end
    end
  end
end
