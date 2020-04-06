require 'test_helper'

module ShopifyCli
  module Core
    class EntryPointTest < MiniTest::Test
      def setup
        ShopifyCli::Core::EntryPoint.stubs(:before_resolve)
      end

      def test_calls_executor_with_args
        args = %w(help argone argtwo)

        Core::Executor.any_instance.expects(:call).with(
          ShopifyCli::Commands::Help,
          'help',
          args.dup[1..-1]
        )
        EntryPoint.call(args)
      end
    end
  end
end
