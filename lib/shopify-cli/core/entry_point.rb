require 'shopify_cli'

module ShopifyCli
  module Core
    module EntryPoint
      class << self
        SKIP_UPDATE = %w(update help for-completion load-dev load-system open)

        def call(args, ctx = Context.new)
          ProjectType.load_type(Project.current_project_type)

          task_registry = ShopifyCli::Tasks::Registry

          before_resolve(args)

          command, command_name, args = ShopifyCli::Resolver.call(args)
          executor = ShopifyCli::Core::Executor.new(ctx, task_registry, log_file: ShopifyCli::LOG_FILE)
          ShopifyCli::Core::Monorail.log.invocation(command_name, args) do
            executor.call(command, command_name, args)
          end
        ensure
          ShopifyCli::Core::Finalize.deliver!
        end

        def before_resolve(args)
          ShopifyCli::Core::Monorail.send_events
          ShopifyCli::Core::Update.record_last_update_time

          unless SKIP_UPDATE.include?(args.first)
            ShopifyCli::Core::Update.auto_update
          end
        end
      end
    end
  end
end
