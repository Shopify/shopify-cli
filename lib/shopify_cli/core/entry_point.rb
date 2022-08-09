require "shopify_cli"

module ShopifyCLI
  module Core
    module EntryPoint
      class << self
        def call(args, ctx = Context.new)
          if ctx.development? && !ctx.testing?
            ctx.warn(
              ctx.message("core.warning.development_version", File.join(ShopifyCLI::ROOT, "bin", ShopifyCLI::TOOL_NAME))
            )
          elsif !ctx.new_version.nil? && !ctx.testing? && !Environment.run_as_subprocess?
            ctx.warn(ctx.message("core.warning.new_version", ShopifyCLI::VERSION, ctx.new_version))
          end

          ProjectType.load_all

          task_registry = ShopifyCLI::Tasks::Registry

          command, command_name, args = ShopifyCLI::Resolver.call(args)
          executor = ShopifyCLI::Core::Executor.new(ctx, task_registry, log_file: ShopifyCLI.log_file)
          ShopifyCLI::Core::Monorail.log(command_name, args) do
            executor.call(command, command_name, args)
          end
        end
      end
    end
  end
end
