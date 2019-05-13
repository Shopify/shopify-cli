require 'shopify_cli'

module ShopifyCli
  module EntryPoint
    class << self
      def call(args)
        ctx = ShopifyCli::Context.new
        task_registry = ShopifyCli::Tasks::Registry
        command, command_name, args = ShopifyCli::Resolver.call(args)
        executor = ShopifyCli::Executor.new(ctx, task_registry, log_file: ShopifyCli::LOG_FILE)
        executor.call(command, command_name, args)
      ensure
        ShopifyCli::Finalize.deliver!
      end
    end
  end
end
