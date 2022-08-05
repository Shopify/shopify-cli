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

      def test_does_not_warn_of_new_version_in_tests
        args = %w(help argone argtwo)

        @context.stubs(
          development?: false,
          new_version: "1.0.0",
        )
        @context.expects(:warn).never
        EntryPoint.call(args, @context)
      end

      def test_warns_of_new_version_in_non_tests_when_not_ignoring_message
        args = %w(help argone argtwo)

        ShopifyCLI::Environment.stubs(
          ignore_upgrade_message?: false,
        )

        @context.stubs(
          development?: false,
          new_version: "1.0.0",
          testing?: false
        )
        @context.expects(:warn).once
        EntryPoint.call(args, @context)
      end

      def test_does_not_warn_of_new_version_in_non_tests_when_ignoring_message
        args = %w(help argone argtwo)

        ShopifyCLI::Environment.stubs(
          ignore_upgrade_message?: true,
        )

        @context.stubs(
          development?: false,
          new_version: "1.0.0",
          testing?: false
        )

        @context.expects(:warn).never
        EntryPoint.call(args, @context)
      end
    end
  end
end
