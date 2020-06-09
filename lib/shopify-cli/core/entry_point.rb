require 'shopify_cli'

module ShopifyCli
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          # Check if the shim is set up by checking whether the old Finalizer FD exists
          begin
            is_shell_shim = false
            IO.open(9) { is_shell_shim = true }
          rescue Errno::EBADF
            # This is expected if the descriptor doesn't exist
          end

          if !ctx.testing? && is_shell_shim
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
