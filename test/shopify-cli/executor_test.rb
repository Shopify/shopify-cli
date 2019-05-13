require 'test_helper'

module ShopifyCli
  class ExecutorTest < MiniTest::Test
    include TestHelpers::Context
    include TestHelpers::FakeTask

    class FakeCommand < ShopifyCli::Command
      prerequisite_task :fake

      def call(_args, _name)
        @ctx.puts('command!')
      end
    end

    def setup
      @log = Tempfile.new
      super
    end

    def test_prerequisite_task
      executor = ShopifyCli::Executor.new(@context, @registry, log_file: @log)
      reg = CLI::Kit::CommandRegistry.new(default: nil, contextual_resolver: nil)
      reg.add(FakeCommand, :fake)
      @context.expects(:puts).with('success!')
      @context.expects(:puts).with('command!')
      executor.call(FakeCommand, 'fake', [])
    end
  end
end
