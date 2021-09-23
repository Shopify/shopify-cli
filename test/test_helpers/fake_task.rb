module TestHelpers
  module FakeTask
    class FakeTask < ShopifyCLI::Task
      def call(ctx)
        ctx.puts("success!")
      end
    end

    class FakeTaskWithArgs < ShopifyCLI::Task
      def call(ctx, *args)
        ctx.puts("success with args #{args.reject(&:empty?).join}!")
      end
    end

    def setup
      @registry = ShopifyCLI::Tasks::TaskRegistry.new
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
