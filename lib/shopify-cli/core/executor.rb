require 'shopify_cli'

module ShopifyCli
  module Core
    class Executor < CLI::Kit::Executor
      def initialize(ctx, task_registry, *args, **kwargs)
        @ctx = ctx || ShopifyCli::Context.new
        @task_registry = task_registry || ShopifyCli::Tasks::TaskRegistry.new
        super(*args, **kwargs)
      end

      def call(command, command_name, args)
        command.prerequisite_tasks.each do |task, _|
          @task_registry[task]&.call(@ctx)
        end
        command.ctx = @ctx
        super
      end
    end
  end
end
