require "shopify_cli"

module ShopifyCLI
  module Core
    class Executor < CLI::Kit::Executor
      def initialize(ctx, task_registry, *args, **kwargs)
        @ctx = ctx || ShopifyCLI::Context.new
        @task_registry = task_registry || ShopifyCLI::Tasks::TaskRegistry.new
        super(*args, **kwargs)
      end

      def call(command, command_name, args)
        command.task_registry = @task_registry
        command.ctx = @ctx
        super
      end
    end
  end
end
