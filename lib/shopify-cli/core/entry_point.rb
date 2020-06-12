require 'shopify_cli'

module ShopifyCli
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          if !ctx.testing? && ctx.capture2e('type __shopify_cli__')
            # Looks like we are in a shell shim. Do not proceed with the command
            ctx.puts(ctx.message('core.warning.shell_shim'))
            return
          end

          if ctx.development?
            ctx.puts(
              ctx.message('core.warning.development_version', File.join(ShopifyCli::ROOT, 'bin', ShopifyCli::TOOL_NAME))
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
