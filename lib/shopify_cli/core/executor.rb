# typed: ignore
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
        with_traps do
          with_logging do |_id|
            command.call(args, command_name)
          end
        end
      end
    end
  end
end
