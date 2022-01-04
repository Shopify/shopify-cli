# typed: ignore
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
    end
  end
end
