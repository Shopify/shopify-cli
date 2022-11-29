require "test_helper"

module ShopifyCLI
  module Core
    class EntryPointTest < MiniTest::Test
      include TestHelpers::Project

      def test_calls_executor_with_args
        args = %w(help argone argtwo)

        Core::Executor.any_instance.expects(:call).with(
          ShopifyCLI::Commands::Help,
          "help",
          args.dup[1..-1]
        )
        EntryPoint.call(args, @context)
      end

      def test_no_warnings_in_tests
        args = %w(help argone argtwo)

        @context.stubs(
          development?: false,
          new_version: "2.99.0",
        )
        @context.expects(:warn).never
        EntryPoint.call(args, @context)
      end

      def test_no_warnings_when_running_as_subprocess
        args = %w(help argone argtwo)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: true,
        )

        @context.stubs(
          development?: false,
          new_version: "2.99.0",
          testing?: false
        )

        @context.expects(:warn).never
        EntryPoint.call(args, @context)
      end

      def test_new_version_warning
        args = %w(help argone argtwo)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: false,
        )

        @context.stubs(
          development?: false,
          new_version: "2.99.0",
          testing?: false
        )
        @context.expects(:warn).with(new_version_message).once
        @context.expects(:warn).with(sunset_message).once
        EntryPoint.call(args, @context)
      end

      def test_app_create_sunset_warning
        args = %w(app create)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: false,
        )

        @context.stubs(
          development?: false,
          new_version: nil,
          testing?: false
        )
        @context.expects(:warn).with(create_app_message).once
        EntryPoint.call(args, @context)
      end

      def test_extension_create_sunset_warning
        args = %w(app extension create)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: false,
        )

        @context.stubs(
          development?: false,
          new_version: nil,
          testing?: false
        )
        @context.expects(:warn).with(create_app_message).once
        EntryPoint.call(args, @context)
      end

      def test_app_sunset_warning
        args = %w(app)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: false,
        )

        @context.stubs(
          development?: false,
          new_version: nil,
          testing?: false
        )
        @context.expects(:warn).with(app_message).once
        EntryPoint.call(args, @context)
      end

      def test_theme_sunset_warning
        args = %w(theme)

        ShopifyCLI::Environment.stubs(
          run_as_subprocess?: false,
        )

        @context.stubs(
          development?: false,
          new_version: nil,
          testing?: false
        )
        @context.expects(:warn).with(theme_message).once
        EntryPoint.call(args, @context)
      end

      private

      def new_version_message
        "{{*}} {{yellow:A new version of Shopify CLI is available! You have version 2.32.0 and the latest version is "\
          "2.99.0.\n\n  To upgrade, follow the instructions for the package manager you’re using:\n  "\
          "{{underline:https://shopify.dev/themes/tools/cli/upgrade-uninstall}}}}\n\n"
      end

      def sunset_message
        "{{*}} {{yellow:Note that CLI 2.x will be sunset on May 31, 2023.}}\n"
      end

      def create_app_message
        "{{*}} {{yellow:Note that this CLI 2.x command will be sunset on April 28, 2023. Check here for instructions "\
          "on how to migrate over to CLI 3.x: {{underline:https://shopify.dev/apps/tools/cli/migrate}}.}}\n"
      end

      def app_message
        "{{*}} {{yellow:Note that CLI 2.x will be sunset on May 31, 2023. Check here for instructions on how to "\
          "migrate over to CLI 3.x: {{underline:https://shopify.dev/apps/tools/cli/migrate}}.}}\n"
      end

      def theme_message
        "{{*}} {{yellow:Note that CLI 2.x will be sunset on May 31, 2023. Check here for instructions on how to "\
          "migrate over to CLI 3.x: {{underline:https://shopify.dev/themes/tools/cli/migrate}}.}}\n"
      end
    end
  end
end
