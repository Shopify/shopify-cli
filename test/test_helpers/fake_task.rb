module TestHelpers
  module FakeTask
    class FakeTask < ShopifyCli::Task
      def call(ctx)
        ctx.puts("success!")
      end
    end

    class FakeTaskWithArgs < ShopifyCli::Task
      def call(ctx, *args)
        ctx.puts("success with args #{args.join}!")
      end
    end

    def setup
      @registry = ShopifyCli::Tasks::TaskRegistry.new
      @registry.add(FakeTask, :fake)
      @registry.add(FakeTaskWithArgs, :fake_with_args)
      super
    end

    def teardown
      @registry = nil
      super
    end
  end
end
