require "shopify_cli"

module ShopifyCLI
  module Core
    class Executor < CLI::Kit::Executor
      ruby2_keywords def initialize(ctx, task_registry, *args)
        @ctx = ctx || ShopifyCli::Context.new
        @task_registry = task_registry || ShopifyCli::Tasks::TaskRegistry.new
        super(*args)
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
