require 'shopify_cli'

module ShopifyCli
  module EntryPoint
    class << self
      SKIP_UPDATE = %w(update help for-completion load-dev load-system open)

      def call(args, ctx = Context.new)
        task_registry = ShopifyCli::Tasks::Registry

        orig_args = args.dup
        before_resolve(args)
        command, command_name, args = ShopifyCli::Resolver.call(args)

        while command.has_more_context?
          command.register_contextual_command
          command, command_name, args = ShopifyCli::Resolver.call(orig_args)
        end

        executor = ShopifyCli::Executor.new(ctx, task_registry, log_file: ShopifyCli::LOG_FILE)
        ShopifyCli::Monorail.log.invocation(command_name, args) do
          executor.call(command, command_name, args)
        end
      ensure
        ShopifyCli::Finalize.deliver!
      end

      def before_resolve(args)
        ShopifyCli::Monorail.send_events
        ShopifyCli::Update.record_last_update_time

        unless SKIP_UPDATE.include?(args.first)
          ShopifyCli::Update.auto_update
        end
      end
    end
  end
end
