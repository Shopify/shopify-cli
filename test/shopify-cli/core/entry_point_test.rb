require 'test_helper'

module ShopifyCli
  module Core
    class EntryPointTest < MiniTest::Test
      include TestHelpers::Project

      def setup
        super
        ShopifyCli::Core::EntryPoint.stubs(:before_resolve)
      end

      def test_calls_executor_with_args
        args = %w(help argone argtwo)

        Core::Executor.any_instance.expects(:call).with(
          ShopifyCli::Commands::Help,
          'help',
          args.dup[1..-1]
        )
        EntryPoint.call(args, @context)
      end
    end
  end
end
