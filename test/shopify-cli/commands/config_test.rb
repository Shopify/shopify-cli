require "test_helper"

module ShopifyCLI
  module Commands
    class ConfigTest < MiniTest::Test
      include TestHelpers::FakeFS

      TEST_FEATURE = :feature_flag_test

      def setup
        super
        ShopifyCLI::Core::Monorail.stubs(:log).yields
      end

      def test_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Config.help)
        run_cmd("config help")
      end

      def test_feature_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Config::Feature.help)
        run_cmd("config feature --help")
      end

      def test_analytics_help_argument_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Config::Analytics.help)
        run_cmd("config analytics --help")
      end

      def test_no_arguments_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Config.help)
        run_cmd("config")
      end

      def test_no_feature_calls_help
        @context.expects(:puts).with(ShopifyCLI::Commands::Config.help)
        run_cmd("config feature")
      end

      def test_will_enable_a_feature_that_is_disabled
        ShopifyCLI::Feature.disable(TEST_FEATURE)
        @context.expects(:puts).with(@context.message("core.config.feature.enabled", TEST_FEATURE))
        run_cmd("config feature #{TEST_FEATURE} --enable")
        assert ShopifyCLI::Feature.enabled?(TEST_FEATURE)
      end

      def test_will_disable_a_feature_that_is_enabled
        ShopifyCLI::Feature.enable(TEST_FEATURE)
        @context.expects(:puts).with(@context.message("core.config.feature.disabled", TEST_FEATURE))
        run_cmd("config feature #{TEST_FEATURE} --disable")
        refute ShopifyCLI::Feature.enabled?(TEST_FEATURE)
      end

      def test_will_enable_analytics_that_is_disabled
        ShopifyCLI::Config.set("analytics", "enabled", false)
        run_cmd("config analytics --enable")
        assert ShopifyCLI::Config.get_bool("analytics", "enabled")
      end

      def test_will_disable_analytics_that_is_enabled
        ShopifyCLI::Config.set("analytics", "enabled", true)
        run_cmd("config analytics --disable")
        refute ShopifyCLI::Config.get_bool("analytics", "enabled")
      end
    end
  end
end
