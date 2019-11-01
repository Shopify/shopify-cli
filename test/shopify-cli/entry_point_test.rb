require 'test_helper'

module ShopifyCli
  class EntryPointTest < MiniTest::Test
    def setup
      ShopifyCli::EntryPoint.stubs(:before_resolve)
    end

    def test_calls_executor_with_args
      args = %w(help argone argtwo)

      Executor.any_instance.expects(:call).with(
        ShopifyCli::Commands::Help,
        'help',
        args.dup[1..-1]
      )
      EntryPoint.call(args)
    end
  end
end
