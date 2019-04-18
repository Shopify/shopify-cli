module ShopifyCli
  class CommandRegistryTest < MiniTest::Test
    include TestHelpers::Context
    include TestHelpers::FakeTask

    class FakeCommand < ShopifyCli::Command
      prerequisite_task :fake_task

      def call(_args, _name)
        @ctx.puts('command!')
      end
    end

    def test_prerequisite_task
      reg = ShopifyCli::CommandRegistry.new(
        default: nil,
        task_registry: @registry,
        ctx: @context
      )
      reg.add(FakeCommand, :fake)
      @context.expects(:puts).with('success!')
      @context.expects(:puts).with('command!')
      klass, _ = reg.lookup_command(:fake)
      cmd = klass.new(@context)
      cmd.call([], nil)
    end
  end
end
