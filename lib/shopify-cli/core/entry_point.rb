require 'shopify_cli'

module ShopifyCli
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          if ctx.development?
            ctx.puts(
              ctx.message('core.development_version_warning', File.join(ShopifyCli::ROOT, 'bin', ShopifyCli::TOOL_NAME))
            )
          end

          ProjectType.load_type(Project.current_project_type)

          task_registry = ShopifyCli::Tasks::Registry

          command, command_name, args = ShopifyCli::Resolver.call(args)
          executor = ShopifyCli::Core::Executor.new(ctx, task_registry, log_file: ShopifyCli::LOG_FILE)
          ShopifyCli::Core::Monorail.log(command_name, args) do
            executor.call(command, command_name, args)
          end
        end
      end
    end
  end
end
