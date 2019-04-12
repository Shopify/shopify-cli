module TestHelpers
  module FakeTask
    class FakeTask < ShopifyCli::Task
      def call(ctx)
        ctx.puts('success!')
      end
    end

    def setup
      @registry = ShopifyCli::Tasks::TaskRegistry.new
      @registry.add(FakeTask, :fake)
      super
    end

    def teardown
      @registry = nil
      super
    end
  end
end
